defmodule Kandires.Repo do
  use Ecto.Repo,
    otp_app: :kandires,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
