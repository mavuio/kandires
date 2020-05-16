defmodule MwQuerytool do
  @moduledoc false
  require Ecto.Query

  def return_query(query, repo, type \\ :model, fields) do
    res =
      case type do
        :model ->
          case fields do
            nil -> query
            _ -> query |> Ecto.Query.select([r], struct(r, ^fields))
          end

        :map ->
          case fields do
            nil -> query
            _ -> query |> Ecto.Query.select([r], map(r, ^fields))
          end

        :tuple ->
          query |> Ecto.Query.select([r], map(r, ^fields))

        :value ->
          query |> Ecto.Query.select([r], map(r, ^fields))

        :count ->
          query

        :query ->
          query
      end

    case type do
      :query -> query
      :tuple -> res |> repo.all() |> Enum.map(&(Map.values(&1) |> List.to_tuple()))
      :value -> res |> repo.all() |> Enum.map(&(Map.values(&1) |> Enum.at(0)))
      :count -> res |> repo.aggregate(:count, :id)
      _ -> res |> repo.all()
    end
  end
end
