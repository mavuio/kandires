defmodule Kandires.MemberC do
  @moduledoc false
  use Memoize

  alias Kandires.Member
  alias Kandires.Repo

  import Ecto.Query, warn: false
  import MwQuerytool, only: [return_query: 4], warn: false

  def get_members(_args) do
    Member
    |> Repo.all()
  end
end
