defmodule KandiresWeb.Shop.Order do
  alias KandiresWeb.Shop.LocalOrder
  alias KandiresWeb.Shop.OrderRecord
  alias Kandis.Checkout
  # alias Kandires.Core.Schemas.ProductVariant
  alias Kandires.Repo
  import Kandis.KdHelpers
  import KandiresWeb.MyHelpers
  import Ecto.Query, warn: false

  def create_orderhtml(orderdata, orderinfo, order_record \\ nil)
      when is_map(orderdata) and is_map(orderinfo) do
    :cool

    Phoenix.View.render(KandiresWeb.ServerView, "orderhtml.html", %{
      orderdata: orderdata,
      orderinfo: orderinfo,
      order: order_record,
      lang: orderdata.lang
    })
  end

  def create_orderdata(ordercart, orderinfo) when is_map(ordercart) and is_map(orderinfo) do
    %{
      lineitems: [],
      stats: %{},
      lang: ordercart.lang
    }
    |> add_lineitems_from_cart(ordercart)
    |> update_stats(orderinfo)
    |> add_product_subtotal(trans(ordercart.lang, "Subtotal", "Zwischensumme"))
    |> LocalOrder.apply_delivery_cost(orderinfo)
    |> update_stats(orderinfo)
    |> add_total(trans(ordercart.lang, "TOTAL", "TOTAL"))
    |> add_total_taxes(orderinfo)
  end

  def add_total_taxes(%{stats: stats} = orderdata, _orderinfo) do
    orderdata
    |> update_in([:lineitems], fn lineitems ->
      new_lineitems =
        stats.taxrates
        |> Map.to_list()
        |> Enum.map(fn {taxrate, tax_stats} ->
          %{
            title: trans(orderdata.lang, "incl. #{taxrate}% VAT", "inkl. #{taxrate}% UST"),
            type: "total_tax",
            total_price: tax_stats.tax
          }
        end)

      lineitems ++ new_lineitems
    end)
  end

  def add_product_subtotal(%{stats: stats} = orderdata, title) when is_binary(title) do
    orderdata
    |> update_in([:lineitems], fn lineitems ->
      new_lineitem = %{
        title: title,
        type: "subtotal",
        total_price: stats.total_price
      }

      lineitems ++ [new_lineitem]
    end)
  end

  def add_total(%{stats: stats} = orderdata, title) when is_binary(title) do
    orderdata
    |> update_in([:lineitems], fn lineitems ->
      new_lineitem = %{
        title: title,
        type: "total",
        total_price: stats.total_price
      }

      lineitems = lineitems |> remove_subtotal_if_lastitem()

      lineitems ++ [new_lineitem]
    end)
  end

  def remove_subtotal_if_lastitem(lineitems) do
    last_item = List.last(lineitems)

    case last_item.type do
      "subtotal" -> List.delete_at(lineitems, length(lineitems) - 1)
      _ -> lineitems
    end
  end

  def add_lineitems_from_cart(orderdata, %{items: cartitems} = _ordercart) do
    orderdata
    |> update_in([:lineitems], fn lineitems ->
      new_lineitems =
        cartitems
        |> Enum.map(&LocalOrder.create_lineitem_from_cart_item(&1))

      lineitems ++ new_lineitems
    end)
  end

  def update_stats(orderdata, _orderinfo) do
    orderdata
    |> update_in([:stats], fn stats ->
      stats
      |> Map.merge(get_stats_for_lineitems(orderdata.lineitems))
    end)
  end

  def get_stats_for_lineitems(lineitems) do
    lineitems
    # skip totals:
    |> Enum.filter(fn a -> not String.contains?(a.type, "total") end)
    |> Enum.reduce(
      %{total_amount: 0, total_price: "0", total_product_price: "0", taxrates: %{}},
      fn item, acc ->
        acc
        |> update_in(
          [:total_amount],
          &(&1 + (item[:amount] || 0))
        )
        |> update_in([:total_price], &Decimal.add(&1, item.total_price))
        |> pipe_when(
          item.type == "product",
          update_in([:total_product_price], &Decimal.add(&1, item.total_price))
        )
        |> pipe_when(
          item.type == "product",
          update_in([:taxrates], &update_taxrate_stats(&1, item))
        )
      end
    )
  end

  def update_taxrate_stats(taxrates = %{}, %{taxrate: taxrate} = item) do
    taxkey = "#{taxrate}"

    taxrates |> IO.inspect(label: "mwuits-debug 2020-03-19_12:30 INCON(#{taxkey})")

    taxrate_item =
      taxrates[taxkey]
      |> if_empty(%{tax: "0", net: "0", gross: "0"})
      |> taxrate_item_append(create_taxrate_stats_entry_for_item(item))

    taxrate_item |> IO.inspect(label: "mwuits-debug 2020-03-19_12:26 AFTEr ")

    taxrates
    |> Map.put(taxkey, taxrate_item)
  end

  def update_taxrate_stats(taxes, _, _), do: taxes

  def taxrate_item_append(map, new_item) when is_map(map) and is_map(new_item) do
    new_item
    |> Map.to_list()
    |> Enum.reduce(map, fn {key, val}, acc ->
      acc
      |> update_in([key], &Decimal.add(&1, val))
    end)
    |> Map.new()
  end

  def create_taxrate_stats_entry_for_item(item) do
    taxfactor = Decimal.div(item.taxrate, 100)
    gross = item.total_price
    net = Decimal.div(item.total_price, Decimal.add(taxfactor, 1))
    tax = Decimal.sub(gross, net)
    %{tax: tax, net: net, gross: gross}
  end

  def extract_shipping_address_fields(orderinfo) when is_map(orderinfo) do
    orderinfo
    |> Map.to_list()
    |> Enum.filter(&String.starts_with?(to_string(elem(&1, 0)), "shipping_"))
    |> Enum.map(fn {key, val} ->
      {String.trim_leading(to_string(key), "shipping_") |> String.to_existing_atom(), val}
    end)
    |> Map.new()
  end

  def atomize_maps(rec) when is_map(rec) do
    rec
    |> update_in([:orderdata], &AtomicMap.convert(&1, safe: true, ignore: true))
    |> update_in([:orderinfo], &AtomicMap.convert(&1, safe: true, ignore: true))
  end

  def atomize_maps(val), do: val

  def get_by_id(id) when is_integer(id) do
    Repo.get(OrderRecord, id)
    |> atomize_maps()
  end

  def get_by_order_nr(order_nr) when is_binary(order_nr) do
    Repo.get_by(OrderRecord, order_nr: order_nr)
    |> atomize_maps()
  end

  def get_by_invoice_nr(invoice_nr) when is_binary(invoice_nr) do
    Repo.get_by(OrderRecord, order_nr: invoice_nr)
    |> atomize_maps()
  end

  def create_new_order(orderdata, orderinfo) do
    Repo.transaction(fn ->
      data = create_order_record_from_checkout(orderdata, orderinfo)

      %OrderRecord{}
      |> OrderRecord.changeset(data)
      |> Repo.insert()
    end)
    |> case do
      {:ok, result} ->
        result
        |> decrement_stock_for_order()

      _ ->
        raise "error while create_new_order"
    end
  end

  def decrement_stock_for_order(order) do
    # select
    order.orderdata.lineitems
    |> Enum.filter(&(&1.type == "product"))
    |> Enum.map(&decrement_for_sku(&1.sku, &1.amount))
  end

  def decrement_for_sku(sku, amount) when is_integer(amount) and is_binary(sku) do
    # pv_id = sku |> Kandis.KdHelpers.to_int()

    # stock =
    #   ProductVariant
    #   |> select([pv], pv.in_stock)
    #   |> where([pv], pv.id == ^pv_id)
    #   |> Repo.one()

    # new_stock = stock - amount

    # %ProductVariant{ID: pv_id}
    # |> ProductVariant.changeset(%{in_stock: new_stock})
    # |> Repo.update()
    # |> elem(0)
  end

  def create_order_record_from_checkout(orderdata, orderinfo)
      when is_map(orderdata) and is_map(orderinfo) do
    %{
      orderinfo: orderinfo,
      orderdata: orderdata,
      order_nr: create_new_order_nr(),
      state: "created",
      user_id: orderinfo[:user_id],
      email: orderinfo[:email],
      payment_type: orderinfo[:payment_type],
      delivery_type: orderinfo[:delivery_type],
      shipping_country: Checkout.get_shipping_country(orderinfo),
      total_price: array_get(orderdata, [:stats, :total_price])
    }
  end

  def create_new_order_nr() do
    nr = get_order_nr_prefix() <> "-" <> get_random_code(4)

    if order_nr_taken?(nr) do
      create_new_order_nr()
    else
      nr
    end
  end

  def order_nr_taken?(order_nr) when is_binary(order_nr) do
    case get_by_order_nr(order_nr) do
      nil -> false
      _ -> true
    end
  end

  def get_random_code(length) do
    Enum.shuffle(~w( A B C D E G H J K L M N P R S T U V X))
    |> Enum.join("")
    |> String.slice(1..length)
  end

  def get_order_nr_prefix() do
    Date.utc_today()
    |> Date.to_string()
    |> String.slice(0..-4)
    |> String.replace("-", "")
  end

  def update(data, _params) do
    id = Kandis.KdHelpers.array_get(data, "id")

    Repo.get!(OrderRecord, id)
    |> OrderRecord.changeset(data)
    |> Repo.insert_or_update!()
  end
end
