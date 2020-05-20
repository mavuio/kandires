defmodule Kandires.DealerC do
  @moduledoc false
  use Memoize

  alias Kandires.Dealer
  alias Kandires.Repo

  import Ecto.Query
  import MwQuerytool, only: [return_query: 4]

  @behaviour Kandires.Behaviours.AgEditable

  @impl true

  def get_record_query_for_controller(_params) do
    fields = [
      :id,
      :title
    ]

    get_records(:query)
    |> select([r], map(r, ^fields))
  end

  def get_records(type \\ :query, fields \\ nil) do
    Dealer
    # |> where([s], fragment("date_part('year', ?)", s.day) == ^year)
    |> return_query(Repo, type, fields)
  end

  @impl true
  def insert_or_update(data, _params) do
    id = MwHelpers.array_get(data, "id")

    case id do
      nil ->
        %Dealer{}

      id ->
        Repo.get!(Dealer, id)
    end
    |> Dealer.changeset(data)
    |> Repo.insert_or_update!()
  end

  @impl true
  def delete(id, _params) do
    %Dealer{id: MwHelpers.to_int(id)}
    |> Repo.delete!()
  end

  # def get_dealer(key) when is_binary(key) do
  #   Repo.get_by(Dealer, key: key)
  # end

  def get_dealer(record_or_id) do
    case record_or_id do
      %Dealer{} = rec -> rec
      id -> Repo.get!(Dealer, MwHelpers.to_int(id))
    end
  end
end
