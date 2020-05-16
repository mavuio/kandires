defmodule KandiresWeb.Router do
  use KandiresWeb, :router
  use Pow.Phoenix.Router
  import Phoenix.LiveView.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowInvitation, PowPersistentSession]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :app do
    plug(KandiresWeb.Plugs.AnonymousUser)
    plug(KandiresWeb.Plugs.DefaultParams)
  end

  pipeline :protected do
    plug(Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    )
  end

  pipeline :require_beuser do
    plug(BasicAuth, use_config: {:kandires, :basicauth})
  end

  scope "/be", KandiresWeb do
    pipe_through(:browser)
    pipe_through(:require_beuser)
    get("/votes", BackendController, :stats)
    get("/voters", BackendController, :list_orders)
    get("/members", BackendController, :list_members)
    get("/votes/:order_nr", BackendController, :show_order)
  end

  scope "/" do
    pipe_through(:browser)
    pow_routes()
    pow_extension_routes()
  end

  scope "/", KandiresWeb do
    pipe_through(:browser)
    pipe_through(:app)

    get("/", PageController, :index)

    match(:*, "/login", Shop.CheckoutController, :step,
      as: :cart,
      assigns: %{"step" => "login"}
    )

    get("/vote", Shop.CheckoutController, :index, as: :checkout)
    match(:*, "/vote/:step", Shop.CheckoutController, :step, as: :checkout_step)
  end

  # scope "/api", KandiresWeb do
  #   pipe_through(:api)
  #   pipe_through(:app)
  #   post("/ag-grid/rows/:table", AgGridController, :get_rows)
  #   post("/ag-grid/paste/:table", AgGridController, :paste)
  #   resources("/ag-grid/:table", AgGridController)
  # end

  # Other scopes may use custom stacks.
  # scope "/api", KandiresWeb do
  #   pipe_through :api
  # end
end
