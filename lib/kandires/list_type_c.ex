defmodule Kandires.ListTypeC do
  @moduledoc false
  use Memoize

  alias Kandires.ListType
  alias Kandires.Dealer
  alias Kandires.Repo

  import Ecto.Query
  import MwHelpers
  import MwQuerytool, only: [return_query: 4]

  @vat_rate "1.165"

  @behaviour Kandires.Behaviours.AgEditable

  @impl true

  def get_record_query_for_controller(_params) do
    fields = [
      :id,
      :key,
      :note,
      :ex_rate,
      :vat_incl,
      :price1,
      :price2,
      :price3,
      :price4,
      :dealer_id
    ]

    get_records(:query)
    |> select([r], map(r, ^fields))
  end

  def get_records(type \\ :query, fields \\ nil) do
    ListType
    # |> where([s], fragment("date_part('year', ?)", s.day) == ^year)
    |> return_query(Repo, type, fields)
  end

  @impl true
  def insert_or_update(data, _params) do
    id = MwHelpers.array_get(data, "id")

    case id do
      nil ->
        %ListType{}

      id ->
        Repo.get!(ListType, id)
    end
    |> ListType.changeset(data)
    |> Repo.insert_or_update!()
  end

  @impl true
  def delete(id, _params) do
    %ListType{id: MwHelpers.to_int(id)}
    |> Repo.delete!()
  end

  def get_list_type(key) when is_binary(key) do
    Repo.get_by(ListType, key: key)
  end

  def get_list_type(record_or_id) do
    case record_or_id do
      %ListType{} = rec -> rec
      id -> Repo.get!(ListType, MwHelpers.to_int(id))
    end
  end

  defmemo get_dealer_for_list_type(type) when is_binary(type), expires_in: 10000 do
    Dealer
    |> join(:left, [d], lt in assoc(d, :list_types))
    |> where([d, lt], lt.key == ^type)
    |> Repo.one()
  end

  defmemo get_factor_for_list(key, fieldname) when is_atom(fieldname), expires_in: 10000 do
    # def get_factor_for_list(key, fieldname) when is_atom(fieldname) do
    rec =
      get_list_type(key)
      |> IO.inspect(label: "get_factor_for_list(#{key}, #{fieldname}) ")

    case rec do
      nil ->
        nil

      rec ->
        rec[fieldname]
        |> apply_rate(rec)
        |> pipe_when(rec[:vat_incl], remove_vat())
    end
  end

  def remove_vat(nil), do: nil

  def remove_vat(val) do
    Decimal.div(val, @vat_rate)
  end

  def apply_rate(nil, _rec), do: nil

  def apply_rate(val, rec) do
    case(rec[:ex_rate]) do
      nil -> val
      rate -> Decimal.mult(val, rate)
    end
  end

  def get_type_keys() do
    ListType
    |> select([c], c.key)
    |> Repo.all()
  end

  def get_colvalues_for_fieldname("dealer_id", _opts \\ []) do
    Dealer
    |> select([d], [d.id, d.title])
    |> Repo.all()
  end
end
