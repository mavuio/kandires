# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :kandires,
  ecto_repos: [Kandires.Repo]

config :kandires, :pow,
  user: Kandires.User,
  repo: Kandires.Repo,
  web_module: KandiresWeb,
  routes_backend: KandiresWeb.Pow.Routes,
  extensions: [PowResetPassword, PowInvitation, PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: KandiresWeb.PowMailer

config :kandires, KandiresWeb.PowMailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: "key-f0633909f0a5bf41fc4015c58663b6ec",
  domain: "shopping.kandires.mw"

# General application configuration
config :kandires,
  ecto_repos: [Kandires.Repo],
  generators: [context_app: :kandires]

# Configures the endpoint
config :kandires, KandiresWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2T9Kov0so9jOahJ6CLcYKHX7qRYjM1k55qFb5XoPb8ZgLQSganAHcUUxrY65PaPZ",
  render_errors: [view: KandiresWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: KandiresWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "S4i7CziI48J7W9hsITxhn0540xAmU0cZ"
  ]

config :logger,
  backends: [:console, {Loggix, :mix_application_log}],
  level: :debug

config :logger, :mix_application_log,
  path: "/www/kandires/logs/mix_application.log",
  format: "##_$level$levelpad | $date $time | $message\n\n",
  rotate: %{max_bytes: 10_485_760, keep: 40}

config :kandis,
  repo: Kandires.Repo,
  pubsub: KandiresWeb.PubSub,
  local_checkout: KandiresWeb.Shop.LocalCheckout,
  local_cart: KandiresWeb.Shop.LocalCart,
  local_order: KandiresWeb.Shop.LocalOrder,
  server_view: KandiresWeb.ServerView,
  order_record: KandiresWeb.Shop.OrderRecord,
  translation_function: &KandiresWeb.MyHelpers.t/3,
  get_pdf_template_url: &KandiresWeb.MyHelpers.get_pdf_template_url/3,
  invoice_nr_prefix: "EBS",
  invoice_nr_testprefix: "EBT",
  steps_module_path: "KandiresWeb.Shop.Checkout.Steps",
  payments_module_path: "KandiresWeb.Shop.Payments",
  pdf_dir: "/www/kandires/pdfs",
  pdf_url: "/pdfs"

config :exi18n,
  default_locale: "en",
  locales: ~w(en de),
  fallback: true,
  loader: :yml,
  loader_options: %{path: "priv/locales"},
  var_prefix: "%{",
  var_suffix: "}"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
