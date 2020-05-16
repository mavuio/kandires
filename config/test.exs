# Since configuration is shared in umbrella projects, this file
# should only configure the :kandires application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :kandires, Kandires.Repo,
  username: "postgres",
  password: "postgres",
  database: "kandires_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kandires, KandiresWeb.Endpoint,
  http: [port: 4002],
  server: false
