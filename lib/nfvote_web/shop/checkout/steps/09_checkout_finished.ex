defmodule KandiresWeb.Shop.Checkout.Steps.CheckoutFinished do
  @moduledoc false

  def process(conn, params) do
    vid = params.vid

    order = Kandis.Order.get_current_order_for_vid(vid)

    if(is_nil(order)) do
      conn
      |> Phoenix.Controller.redirect(to: KandiresWeb.Shop.LocalCheckout.get_cart_basepath(params))
      |> Plug.Conn.halt()
    end

    conn
    |> Plug.Conn.merge_assigns(
      lang: params["lang"],
      order: order,
      orderhtml: Kandis.Order.get_orderhtml(order)
    )
  end
end
