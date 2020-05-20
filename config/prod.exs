use Mix.Config

# Do not print debug messages in production
config :logger, level: :info

config :kandires, KandiresWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4004],
  url: [host: "kandires.werkzeugh.at", scheme: "https", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  debug_errors: true,
  check_origin: false

config :kandires,
  uploads_directory: "/www/kandires/temp",
  prod_imgs_directory: "/www/kandires/imgs",
  pdftotext_cmd: "/usr/bin/pdftotext"

config :kandis,
  local_url: "https://kandires.werkzeugh.at"

import_config "prod.secret.exs"

config :kandires, KandiresWeb.Endpoint,
  # Possibly not needed, but doesn't hurt
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 80],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  server: true

config :kandires, Kandires.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  # Free tie
  pool_size: 2
