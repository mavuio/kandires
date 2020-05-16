defmodule KandiresWeb.Shop.Promocodes do
  import Kandis.KdHelpers, warn: false
  import KandiresWeb.MyHelpers, warn: false
  alias Kandis.Cart

  def promocode_is_valid?(code, cart_record \\ %{})

  def promocode_is_valid?(code, cart_record)
      when is_binary(code) and is_map(cart_record) do
    get_promocode_record(code, cart_record)
    |> case do
      %{valid: true} -> true
      %{valid_until: end_date} when is_binary(end_date) -> to_string(Date.utc_today()) < end_date
      _ -> false
    end
  end

  def promocode_is_valid?(nil, _), do: false

  def get_promocode_record("NEWSHOP10", params) do
    %{
      title: trans(params, "OPENING-special: 10% off", "OPENING-special: 10% Rabatt"),
      valid_until: "2020-04-03",
      percentage_off: "10"
    }
  end

  def get_promocode_record(_, _) do
    nil
  end

  def augment_cart_with_promocodes(cart_record, params) do
    Cart.get_promocodes(cart_record)
    |> Enum.reduce(cart_record, fn promocode, acc ->
      apply_promocode_to_cart(acc, promocode, params)
    end)
    |> IO.inspect(label: "mwuits-debug 2020-03-24_13:5A ")
  end

  def apply_promocode_to_cart(cart_record, promocode, params) do
    promocode_record =
      get_promocode_record(promocode, params)
      |> calculate_promocode_price(cart_record, params)

    cart_record
    |> pipe_when(promocode_record, Cart.add_item(promocode, promocode_record, :promocode))
  end

  # def apply_promocode_to_cart(cart_record, _, _params) do
  #   cart_record
  # end

  def calculate_promocode_price(promocode_record, cart_record, _params) do
    total_price =
      cond do
        present?(promocode_record[:percentage_off]) ->
          Decimal.mult(
            Decimal.div(promocode_record[:percentage_off] |> to_dec(), -100),
            cart_record[:total_price]
          )

        true ->
          nil
      end

    promocode_record
    |> pipe_when(total_price, Map.put(:total_price, total_price))
  end
end
