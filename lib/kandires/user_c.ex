defmodule Kandires.UserC do
  @moduledoc false
  use Memoize

  alias Kandires.User
  alias Kandires.Repo

  import Ecto.Query
  # import MwHelpers
  import MwQuerytool, only: [return_query: 4]

  @behaviour Kandires.Behaviours.AgEditable

  @impl true

  def get_record_query_for_controller(_params) do
    fields = [
      :id,
      :email,
      :pricefield,
      :name,
      :company,
      :address,
      :phone,
      :tpin,
      :vat_type
    ]

    get_records(:query)
    |> select([r], map(r, ^fields))
  end

  def get_records(type \\ :query, fields \\ nil) do
    User
    # |> where([s], fragment("date_part('year', ?)", s.day) == ^year)
    |> return_query(Repo, type, fields)
  end

  @impl true
  def insert_or_update(data, _params) do
    id = MwHelpers.array_get(data, "id")

    case id do
      nil ->
        %User{}

      id ->
        Repo.get!(User, id)
    end
    |> User.changeset(Map.put(data, "is_backend_request", true))
    |> Repo.insert_or_update!()
  end

  @impl true
  def delete(id, _params) do
    %User{id: MwHelpers.to_int(id)}
    |> Repo.delete!()
  end

  def get_user(key) when is_binary(key) do
    Repo.get_by(User, key: key)
  end

  def get_user(record_or_id) do
    case record_or_id do
      %User{} = rec -> rec
      id -> get_user_by_id(id)
    end
  end

  def get_user_by_id(nil), do: nil

  def get_user_by_id(id) do
    Repo.get!(User, MwHelpers.to_int(id))
  end

  def add_user_to_params_using_vid(%{"vid" => "user." <> userid} = params) do
    params |> Map.put(:current_user, get_user_by_id(userid))
  end

  def add_user_to_params_using_vid(%{:vid => "user." <> userid} = params) do
    params |> Map.put(:current_user, get_user_by_id(userid))
  end

  def add_user_to_params_using_vid(params), do: params
end
