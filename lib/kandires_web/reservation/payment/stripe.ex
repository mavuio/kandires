defmodule KandiresWeb.Reservation.PaymentStripe do
  def test_intent() do
    create_intent("10.99", %{"metadata[integration_check]" => "accept_a_payment"})
  end

  def create_intent(amount, data \\ %{}, currency \\ "eur") do
    centamount =
      Decimal.mult(amount, 100)
      |> Decimal.to_integer()

    data =
      %{
        "amount" => centamount,
        "currency" => currency
      }
      |> Map.merge(data)

    case Stripy.req(:post, "payment_intents", data) do
      {:ok, response} ->
        response.body
        |> Jason.decode()
        |> case do
          {:ok, response_data} ->
            response_data
            |> Map.get("client_secret")

          _ ->
            nil
        end

      _ ->
        nil
    end

    #   curl https://api.stripe.com/v1/payment_intents \
    # -u sk_test_HUKNp1eAFnKfg4dPAzY6X11Q00U6wB1FAQ: \
    # -d amount=1099 \
    # -d currency=eur \
    # -d "metadata[integration_check]"=accept_a_payment
  end
end
