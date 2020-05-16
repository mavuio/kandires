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
