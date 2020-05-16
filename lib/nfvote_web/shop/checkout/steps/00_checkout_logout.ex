defmodule KandiresWeb.Shop.Checkout.Steps.CheckoutLogout do
  @moduledoc false

  alias Kandis.Checkout, warn: false

  def process(conn, params) do
    vid = params[:vid]

    if vid do
      Kandis.VisitorSession.set_value(vid, "cart", nil)
      Kandis.VisitorSession.set_value(vid, "checkout", nil)
    end

    conn
    |> Phoenix.Controller.put_flash(
      :info,
      "du wurdest abgemeldet"
    )
    |> Phoenix.Controller.redirect(to: KandiresWeb.Router.Helpers.cart_path(conn, :step))
    |> Plug.Conn.halt()
  end
end
