defmodule KandiresWeb.Reservation.LocalOrder do
  def create_lineitem_from_cart_item(item) when is_map(item) do
    item
  end

  def apply_delivery_cost(orderdata, _orderinfo), do: orderdata

  def get_stats(orders) when is_list(orders) do
    participants = length(orders)

    orders
    |> Enum.reduce(%{}, fn o, acc ->
      o.orderdata["lineitems"]
      |> Enum.reduce(acc, fn li, acc ->
        # {acc, li} |> IO.inspect(label: "mwuits-debug 2020-05-08_14:41 ")

        update_in(acc, [Access.key(li["key"], %{}), Access.key(li["result"], 0)], fn val ->
          val + 1
        end)

        # |> IO.inspect(label: "mwuits-debug 2020-05-08_14:42 ➜ ")
      end)
    end)
    |> percentize(participants)
  end

  def percentize(stats, participants) when is_map(stats) do
    stats
    |> Map.to_list()
    |> Enum.filter(fn {pkt, _} -> not is_nil(pkt) end)
    |> Enum.map(fn {pkt, sums} ->
      %{
        pkt: pkt,
        title: KandiresWeb.MyHelpers.t("de", "points.#{pkt}"),
        sums:
          Enum.map(sums, fn {key, val} ->
            {
              key,
              %{
                val: val,
                perc: val / participants * 100
              }
            }
          end)
          |> Map.new()
      }
    end)
  end
end
