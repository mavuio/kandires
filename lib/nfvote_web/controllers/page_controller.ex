defmodule KandiresWeb.PageController do
  alias Kandires.ProdC
  alias Kandires.CategoryC
  alias Kandis.Cart
  alias Kandis.Order
  use KandiresWeb, :controller
  import MwHelpers

  def index(conn, params) do
    render(conn, "index.html", params: params)
  end

  def login(conn, params) do
    render(conn, "login.html", params: params)
  end

  def add_to_cart(conn, %{"quantities" => quantities, vid: vid} = _params) do
    res = Cart.add_items(vid, quantities)
    json(conn, %{payload: res})
  end

  def get_cart_count(conn, %{vid: vid}) do
    res = Cart.get_cart_count(vid)
    json(conn, %{payload: res})
  end

  def variant_list(conn, _params) do
    render(conn, "variant_list.html")
  end

  def show_pdf(conn, %{"mode" => mode, "order_nr" => order_nr} = params) do
    with file when is_binary(file) <- Order.get_order_file(order_nr, mode, params) do
      conn
      |> put_resp_content_type("application/pdf")
      |> Plug.Conn.send_file(200, file)
    else
      _ -> conn |> text("quote-pdf not found")
    end
  end

  def html_for_pdf(conn, %{"mode" => mode, "order_nr" => order_nr} = _params) do
    order = Order.get_by_order_nr(order_nr)

    orderhtml = Order.get_orderhtml(order, mode)
    conn = conn |> put_layout("backend_empty.html")
    render(conn, "pdf_html.html", %{order: order, orderhtml: orderhtml})
  end
end
