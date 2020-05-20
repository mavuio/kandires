defmodule KandiresWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :kandires

  @session_options [
    store: :cookie,
    key: "_kandires_web_key",
    signing_salt: "KK1GvsI3",
    extra: "SameSite=None",
    secure: true
  ]

  socket("/socket", KandiresWeb.UserSocket,
    websocket: true,
    longpoll: false
  )

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :kandires,
    gzip: false,
    only: ~w(css fonts images js engine favicon.ico robots.txt),
    headers: %{"Access-Control-Allow-Origin" => "*"}
  )

  plug(Plug.Static,
    at: "/uploads/",
    from: Application.get_env(:kandires, :uploads_directory),
    gzip: true
  )

  plug(Plug.Static,
    at: "/pdfs",
    from: Elixir.Application.get_env(:kandis, :pdf_dir)
  )

  plug(Plug.Static,
    at: "/prod_imgs/",
    from: Application.get_env(:kandires, :prod_imgs_directory),
    gzip: true
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.

  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session, @session_options)

  plug(Pow.Plug.Session,
    otp_app: :kandires,
    credentials_cache_store:
      {Pow.Store.CredentialsCache, ttl: :timer.minutes(30), namespace: "credentials"},
    session_ttl_renewal: :timer.minutes(15)
  )

  plug(PowPersistentSession.Plug.Cookie)

  plug(CORSPlug,
    origin: &KandiresWeb.EmbedView.cors_hosts/1
  )

  plug(KandiresWeb.Router)
end
