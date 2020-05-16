defmodule KandiresWeb.Shop.Checkout.Steps.CheckoutLogin do
  @moduledoc false
  use Phoenix.LiveView

  # alias Kandis.VisitorSession
  alias Kandis.Cart
  alias Kandis.Checkout, warn: false
  alias Kandires.Repo
  import Kandis.KdHelpers

  # import KandiresWeb.MyHelpers

  use KandiresWeb.Live.AuthHelper

  def process(conn, _params) do
    conn
    |> Plug.Conn.assign(:live_module, __MODULE__)
  end

  def render(assigns) do
    Phoenix.View.render(KandiresWeb.PageView, "checkout_login.html", assigns)
  end

  def mount(_params, session, socket) do
    vid = session["vid"]

    {:ok,
     assign(socket,
       vid: vid,
       login_msg: nil
     )}
  end

  def handle_event("check_mglnr", %{"mglnr" => mglnr}, socket) do
    user_record =
      get_member_for_mglnr(
        mglnr
        |> if_nil("")
        |> String.trim()
      )

    # Promocodes.promocode_is_valid?(code, socket.assigns.cart)
    case user_record do
      nil ->
        login_msg = "✖ diese Nummer ist leider nicht gültig"
        {:noreply, assign(socket, login_msg: login_msg)}

      user_record when is_map(user_record) ->
        handle_successfull_login(socket, user_record)
    end
  end

  def handle_successfull_login(socket, user_record) when is_map(user_record) do
    vid = socket.assigns[:vid]
    cart_id = "nf.#{user_record.mglnr}"
    order = Kandis.Order.get_by_cart_id(cart_id)

    if is_map(order) do
      login_msg =
        "✖ mit dieser Mitgliedsnummer wurde bereits abgestimmt " <>
          (KandiresWeb.MyHelpers.format_date(order.inserted_at)
           |> to_string())

      {:noreply, assign(socket, login_msg: login_msg)}
    else
      Cart.add_item(vid, "stimmrecht")
      |> Map.put(:cart_id, cart_id)
      |> Cart.store_cart_record_if_needed(vid)

      checkout_record =
        Checkout.get_empty_checkout_record()
        |> Map.merge(user_record)

      Kandis.VisitorSession.set_value(vid, Checkout.get_visitorsession_key(), checkout_record)

      {:noreply,
       socket |> redirect(to: KandiresWeb.Shop.LocalCheckout.default_step_link(socket, []))}
    end
  end

  def get_member_for_mglnr("0815" = mglnr) do
    %{
      firstname: "Maria",
      lastname: "Muster",
      gender: "f",
      mglnr: mglnr
    }
  end

  def get_member_for_mglnr("0816" = mglnr) do
    %{
      firstname: "Max",
      lastname: "Muster",
      gender: "m",
      mglnr: mglnr
    }
  end

  def get_member_for_mglnr(mglnr) do
    Repo.get_by(Kandires.Member, mglnr: mglnr)
    |> case do
      nil -> nil
      rec -> Map.from_struct(rec)
    end
  end

  def handle_info(msg, socket) do
    msg |> IO.inspect(label: "UNKNOWN MSG received by cart")
    {:noreply, socket}
  end
end
