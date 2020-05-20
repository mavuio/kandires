defmodule Kandires.CategoryC do
  @moduledoc false
  use Memoize

  alias Kandires.Category
  alias Kandires.Repo
  alias Kandires.Prod

  import Ecto.Query
  # import MwHelpers
  import MwQuerytool, only: [return_query: 4]

  @behaviour Kandires.Behaviours.AgEditable

  @impl true

  def get_record_query_for_controller(_params) do
    fields = [
      :id,
      :title,
      :ancestry
    ]

    get_records(:query)
    |> select([r], map(r, ^fields))
  end

  def get_records(type \\ :query, fields \\ nil) do
    Category
    # |> where([s], fragment("date_part('year', ?)", s.day) == ^year)
    |> return_query(Repo, type, fields)
  end

  @impl true
  def insert_or_update(data, _params) do
    id = MwHelpers.array_get(data, "id")

    case id do
      nil ->
        %Category{}

      id ->
        Repo.get!(Category, id)
    end
    |> Category.changeset(data)
    |> Repo.insert_or_update!()
  end

  @impl true
  def delete(id, _params) do
    %Category{id: MwHelpers.to_int(id)}
    |> Repo.delete!()
  end

  def get_category(nil), do: nil

  def get_category(title) when is_binary(title) do
    Repo.get_by(Category, title: title)
  end

  def get_category(record_or_id) do
    case record_or_id do
      %Category{} = rec -> rec
      id -> Repo.get!(Category, MwHelpers.to_int(id))
    end
  end

  def get_paths_from_prod() do
    Prod
    |> select([a], a.path)
    |> distinct(true)
    |> Repo.all()
  end

  def import_categories_from_prod do
    get_paths_from_prod()
    |> Enum.map(&handle_path/1)
  end

  def handle_path(str) do
    parts =
      str
      |> String.split("/")
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&import_category/1)

    # |> Enum.filter(&MwHelpers.present?/1)

    # parts |> IO.inspect(label: "handle path#{str}")
  end

  def import_category(["" = parent_title, title]) do
    {title, parent_title} |> IO.inspect(label: "import_category ")

    ancestry = nil

    case get_category(title) do
      nil ->
        %Category{}
        |> Category.changeset(%{title: title, ancestry: ancestry})
        |> Repo.insert!()

      %Category{} ->
        :already_exists
    end
  end

  def import_category([parent_title, title]) do
    parent_cat = get_category(parent_title)

    if parent_cat do
      ancestry =
        case parent_cat.ancestry do
          nil ->
            "#{parent_cat.id}"

          # {parent_cat.id}"
          str when is_binary(str) ->
            "#{parent_cat.ancestry}/#{parent_cat.id}"
        end

      case get_category(title) do
        nil ->
          %Category{}
          |> Category.changeset(%{title: title, ancestry: ancestry})
          |> Repo.insert!()

        %Category{} ->
          :already_exists
      end
    end
  end

  def get_path(cat_or_id) do
    cat = get_category(cat_or_id)

    "/" <>
      (Category.path(cat)
       |> Enum.map(fn a -> a.title end)
       |> Enum.join("/"))
  end

  def get_tree() do
    root = Category.roots() |> Enum.at(0)
    Category.arrange(root)
  end
end
