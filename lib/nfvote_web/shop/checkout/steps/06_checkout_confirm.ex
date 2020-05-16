defmodule KandiresWeb.Shop.Checkout.Steps.CheckoutConfirm do
  @moduledoc false
  @step "confirm"

  def process(conn, params) do
    vid = params[:vid]

    conn =
      conn
      |> Kandis.Checkout.redirect_if_empty_cart(vid, params)

    if conn.halted do
      conn
    else
      create_order(vid, params)

      conn
      |> Phoenix.Controller.redirect(to: Kandis.Checkout.get_next_step_link(params, @step))
      |> Plug.Conn.halt()
    end
  end

  def create_order(vid, params) do
    order = Kandis.Checkout.create_order_from_checkout(vid, params)

    # Kandis.Order.cancel_orders_for_cart_id(order.orderdata.cart_id)

    order = Kandis.Order.set_state(order.id, "finished")
    Kandis.Cart.remove_item(vid, "stimmrecht")
  end
end
