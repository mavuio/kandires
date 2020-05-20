defmodule KandiresWeb.Reservation.CheckoutController do
  use KandiresWeb, :controller

  alias Kandis.Checkout

  def index(conn, params) do
    conn |> Checkout.redirect_to_default_step(params)
  end

  def step(conn, params) do
    conn =
      conn
      |> Checkout.process(Map.merge(conn.assigns, params))

    if conn.halted do
      conn |> IO.inspect(label: "mwuits-debug 2020-04-29_14:44 REDIRECT")
    else
      conn =
        conn
        |> put_view(KandiresWeb.PageView)

      case conn.assigns[:live_module] do
        nil ->
          render(conn, conn.assigns[:template_name], params)

        module_name ->
          live_render(conn, module_name,
            session:
              params
              |> Kandis.KdHelpers.convert_keys([:vid], &to_string/1)
              |> Kandis.KdHelpers.drop_keys_by_type(:atom)
          )
      end
    end
  end

  def callback(conn, params) do
    conn
    |> Payment.process_callback(Map.merge(conn.assigns, params))
  end
end
