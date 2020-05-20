defmodule KandiresWeb.BackendController do
  use KandiresWeb, :controller
  alias Kandis.Order
  alias KandiresWeb.Reservation.LocalOrder
  alias Kandires.MemberC
  plug(:put_layout, {KandiresWeb.LayoutView, "backend.html"})

  def index(conn, params) do
    params |> IO.inspect(label: "mwuits-debug 2020-02-28_19:16 ")
    render(conn, "index.html")
  end

  def prod_list(conn, _params) do
    render(conn, "prod_list.html")
  end

  def list_types(conn, _params) do
    render(conn, "list_types.html")
  end

  def dealers(conn, _params) do
    render(conn, "dealers.html")
  end

  def user_list(conn, _params) do
    render(conn, "user_list.html")
  end

  def variant_list(conn, _params) do
    render(conn, "variant_list.html")
  end

  def stats(conn, params) do
    members = MemberC.get_members(params)
    orders = Order.get_orders(params)
    stats = LocalOrder.get_stats(orders)
    render(conn, "stats.html", %{orders: orders, stats: stats, members: members})
  end

  def list_members(conn, params) do
    members = MemberC.get_members(params)
    orders = Order.get_orders(params)
    stats = LocalOrder.get_stats(orders)
    render(conn, "list_members.html", %{orders: orders, stats: stats, members: members})
  end

  def list_orders(conn, params) do
    members = MemberC.get_members(params)
    orders = Order.get_orders(params)
    stats = LocalOrder.get_stats(orders)
    render(conn, "list_orders.html", %{orders: orders, stats: stats, members: members})
  end

  def show_order(conn, %{"order_nr" => order_nr} = _params) do
    order = Order.get_by_order_nr(order_nr)
    orderhtml = Order.get_orderhtml(order)
    render(conn, "show_order.html", %{order: order, orderhtml: orderhtml})
  end
end
