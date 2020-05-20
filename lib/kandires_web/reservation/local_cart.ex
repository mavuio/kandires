defmodule KandiresWeb.Reservation.LocalCart do
  alias Kandires.ProdC
  alias Kandires.Core.Schemas.ProductVariant, warn: false
  alias Kandires.Repo, warn: false
  import Ecto.Query, warn: false
  import Kandis.KdHelpers
  alias Kandis.Cart, warn: false
  alias KandiresWeb.Reservation.Promocodes, warn: false

  def augment_cart_items(items, params) when is_list(items) do
    items
    |> Enum.map(fn a ->
      ProdC.get_product_variant(a.sku |> Kandis.KdHelpers.to_int(), params)
      |> case do
        nil ->
          nil

        variant ->
          item =
            a
            |> Map.merge(variant)

          item
          |> Map.put(:total_price, Decimal.mult(item.price || "0", item.amount))
          |> Map.put(:total_price_incl, Decimal.mult(item.price_incl || "0", item.amount))
          |> Map.put(:type, "product")
      end
    end)
    |> Enum.filter(&present?/1)
  end

  def augment_cart(cart_record, params) do
    cart_record
    |> update_in([:items], fn items -> items |> augment_cart_items(params) end)
    |> count_totals(params)

    # |> pipe_when(
    #   present?(cart_record[:promocodes]),
    #   Promocodes.augment_cart_with_promocodes(params)
    #   |> count_totals(params)
    # )
  end

  def count_totals(cart_record, _params) do
    stats =
      cart_record.items
      |> Enum.reduce(%{total_items: 0, total_price: "0", total_price_incl: "0"}, fn el, acc ->
        acc
        |> update_in([:total_items], fn val -> val + el.amount end)
        |> update_in([:total_price], fn val ->
          Decimal.add(val, el.total_price)
        end)
        |> update_in([:total_price_incl], fn val ->
          Decimal.add(val, el.total_price_incl)
        end)
      end)

    cart_record
    |> Map.merge(stats)
  end

  def get_max_for_sku(_sku) do
    100

    # pv_id = sku |> Kandis.KdHelpers.to_int()

    # if pv_id do
    #   ProductVariant
    #   |> select([pv], pv.in_stock)
    #   |> where([pv], pv.id == ^pv_id)
    #   |> Repo.one()
    #   |> Kandis.KdHelpers.if_empty(:infinity)
    # else
    #   :infinity
    # end
  end
end
