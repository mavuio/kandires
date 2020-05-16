defmodule KandiresWeb.AgGridController do
  @moduledoc false

  use KandiresWeb, :controller
  alias Kandires.Repo
  require Ecto.Query
  import MwHelpers

  def get_module_name(table) do
    String.to_existing_atom("Elixir.Kandires." <> Macro.camelize(table) <> "C")
  end

  def index(conn, %{"table" => table} = params) do
    module_name = get_module_name(table)
    query = apply(module_name, :get_record_query_for_controller, [params])

    requests_colvalues = params["colvalues"]

    id = array_get(params, "id") |> to_int()

    payload =
      case query do
        {colnames, items} when is_list(items) ->
          col_defs_from_colnames = create_col_defs_from_colnames(colnames)
          col_defs_from_data = create_col_defs_from_data(items)
          col_defs = merge_col_defs(col_defs_from_colnames, col_defs_from_data)

          %{
            entries: items |> pipe_when(id, Enum.filter(fn r -> r.id == id end)),
            col_defs: col_defs
          }

        items when is_list(items) ->
          col_defs = create_col_defs_from_data(items)

          %{
            entries: items |> pipe_when(id, Enum.filter(fn r -> r.id == id end)),
            col_defs: col_defs
          }

        query ->
          col_defs_from_query = create_col_defs_from_query(query)

          query =
            query
            |> fix_hidden_fields_in_query()
            |> pipe_when(id, Ecto.Query.where([r], r.id == ^id))

          # |> MwError.die(label: "mwuits-debug 2020-01-28_17:03 ")

          payload =
            case params do
              %{"startRow" => startRow, "endRow" => endRow} ->
                num = endRow - startRow

                total_entries =
                  Map.get_lazy(params, "total_entries", fn ->
                    KandiresWeb.ScrivenerTotals.total_entries(query, Repo, [])
                  end)

                final_query =
                  Ecto.Query.limit(query, ^num)
                  |> Ecto.Query.offset(^startRow)

                %{
                  entries: Repo.all(final_query),
                  total_entries: total_entries
                }

              _ ->
                final_query = Ecto.Query.limit(query, 10000_0)

                %{
                  entries: Repo.all(final_query)
                }
            end

          # |> IO.inspect(label: "mwuits-debug 2020-01-07_11:37 ")

          # |> Map.from_struct()

          # payload =
          #   if array_get(params, "decorate") do
          #     hd(payload.entries) |> IO.inspect(label: "mwuits-debug 2019-02-19_18:25 ")
          #   else
          #     payload
          #   end

          col_defs_from_data = create_col_defs_from_data(payload.entries)

          # require IEx
          # IEx.pry()

          col_defs = merge_col_defs(col_defs_from_query, col_defs_from_data)

          # {col_defs_from_query, col_defs_from_data}
          # |> IO.inspect(label: "merge_col_defs")

          payload = Map.put(payload, :col_defs, col_defs)

          payload
          |> pipe_when(
            query_contains_loadable_fields?(query),
            Map.update!(:entries, &load_fields_for_entries(&1, module_name))
          )
          |> pipe_when(
            not is_nil(requests_colvalues),
            Map.put(:colvalues, get_colvalues(requests_colvalues, module_name, params))
          )
      end

    payload = Map.update!(payload, :entries, &replace_decimals_with_floats/1)

    # |> MwHelpers.log("mwuits-debug 2019-02-19_17:11 ", :warn)

    json(conn, %{payload: payload})
  end

  def get_colvalues(colvalue_fieldnames, module_name, params) do
    colvalue_fieldnames
    |> String.split(",")
    |> Enum.filter(&present?/1)
    |> Enum.reduce(%{}, fn fieldname, acc ->
      Map.put(acc, fieldname, get_colvalues_for_fieldname(fieldname, module_name, params))
    end)
  end

  def get_colvalues_for_fieldname(fieldname, module_name, params) do
    params = Map.put(params, "fieldname", fieldname)

    fieldname_atom = String.to_atom(fieldname)
    fieldlist = [fieldname_atom]

    if Kernel.function_exported?(module_name, :get_colvalues_for_fieldname, 2) do
      apply(module_name, :get_colvalues_for_fieldname, [fieldname, params])
    else
      apply(module_name, :get_record_query_for_controller, [params])
      |> Ecto.Query.exclude(:select)
      |> Ecto.Query.select(^fieldlist)
      |> Ecto.Query.distinct(true)
      |> Repo.all()
      |> Enum.map(fn row -> row[fieldname_atom] end)
      |> Enum.filter(&MwHelpers.present?/1)
    end
  end

  def fix_hidden_fields_in_query(%Ecto.Query{select: select} = query) when not is_nil(select) do
    update_in(
      query,
      [Access.key(:select), Access.key(:expr), Access.elem(2), Access.all()],
      fn
        {key, val} ->
          case Atom.to_string(key) do
            "__" <> new_key -> {String.to_atom(new_key), val}
            _ -> {key, val}
          end

        val ->
          val
      end
    )
  end

  def fix_hidden_fields_in_query(other_query) do
    other_query
  end

  def replace_decimals_with_floats(entries) do
    entries
    |> Enum.map(fn entry ->
      entry
      |> Map.to_list()
      |> Enum.map(&decimal_to_float_in_pair/1)
      |> Map.new()
    end)
  end

  defp decimal_to_float_in_pair({key, %Decimal{} = val}) do
    {key, val |> Decimal.round(4) |> Decimal.to_float()}
  end

  defp decimal_to_float_in_pair({key, val}) do
    {key, val}
  end

  # defp get_numeric_fields_from_col_defs(col_defs) do
  #   col_defs
  #   |> Enum.filter(fn
  #     %{:type => "numericColumn"} ->
  #       true

  #     _ ->
  #       false
  #   end)
  #   |> Enum.map(fn a -> a.field end)
  # end

  def load_fields_for_entries(entries, module_name) do
    entries
    |> Enum.map(&load_fields_for_single_entry(&1, module_name))
  end

  def load_fields_for_single_entry(entry, module_name) do
    entry
    |> Map.to_list()
    |> Enum.map(&load_field(&1, entry, module_name))
    |> Map.new()
  end

  def load_field({key, "__" <> definition = value}, rec, module_name) when is_binary(value) do
    {key, load_value_for_autogenerated_field(rec, definition, module_name)}
  end

  def load_field(pair, _rec, _module_name) do
    pair
  end

  def load_value_for_autogenerated_field(rec, definition, module_name) do
    [function_name | arguments] =
      definition
      |> String.split(",")

    apply(module_name, String.to_existing_atom(function_name), [rec] ++ arguments)
  end

  # def create_col_def_from_query_or_data(%Ecto.Query{select: select} = query, _data)
  #     when not is_nil(select) do
  #   create_col_def_from_query(query)
  # end

  # def create_col_def_from_query_or_data(_query, data) do
  #   create_col_def_from_data(data)
  # end

  def create_col_defs_from_colnames(colnames) when is_list(colnames) do
    colnames
    |> Enum.reduce(
      [],
      fn fieldname, acc ->
        acc ++ [%{field: "#{fieldname}"}]
      end
    )
  end

  def create_col_defs_from_query(query) do
    query
    |> Ecto.Queryable.to_query()
    |> array_get([:select, :expr], {nil, nil, nil})
    |> case do
      # do not handle merge-queries
      {:merge, _, _} ->
        {nil, nil, nil}

      b ->
        b
    end
    |> elem(2)
    |> case do
      nil ->
        nil

      [0] ->
        array_get(query, [:select, :take])
        |> Map.get(0)
        |> elem(1)
        |> Enum.reduce([], &accumulate_col_def_for_field/2)

      items ->
        Enum.map(items, fn
          {key, _} -> key
          item -> item
        end)
        |> Enum.reduce([], &accumulate_col_def_for_field/2)
    end
  end

  def accumulate_col_def_for_field({key, val}, acc) do
    fieldname = "#{key}"

    case fieldname do
      # skip fields prefixed with __
      "__" <> _ ->
        acc

      _ ->
        acc ++ [get_col_def_for_field(fieldname, val)]
    end
  end

  def accumulate_col_def_for_field(field, acc) do
    accumulate_col_def_for_field({field, nil}, acc)
  end

  def create_col_defs_from_data(entries) do
    case entries do
      [first_entry | _] ->
        first_entry
        |> Map.to_list()
        |> Enum.reduce([], &accumulate_col_def_for_field/2)

      _ ->
        nil
    end
  end

  def get_col_def_for_field(fieldname, %Decimal{}) do
    get_col_def_for_field(fieldname, 1)
    |> Map.put(:type, "numericColumn")
  end

  def get_col_def_for_field(fieldname, value) when is_integer(value) do
    get_col_def_for_field(fieldname, nil)
    |> Map.put(:type, "integerColumn")
  end

  def get_col_def_for_field(fieldname, _value) do
    %{
      field: fieldname,
      headerName: Recase.to_title("#{fieldname}")
    }
  end

  def merge_col_defs(nil, from_data) do
    from_data
  end

  def merge_col_defs(from_query, nil) do
    from_query
  end

  def merge_col_defs(from_query, from_data) do
    # take from_query,enrich with from_data
    # {from_query, from_data} |> MwError.die(label: "mwuits-debug 2019-03-06_13:09 ")

    Enum.reduce(from_query, [], fn col_def, acc ->
      new_col_def =
        case Enum.find(from_data, fn a -> a.field == col_def.field end) do
          nil -> col_def
          %{} = extended_col_def -> Map.merge(col_def, extended_col_def)
        end

      acc ++ [new_col_def]
    end)
  end

  def query_contains_loadable_fields?(%Ecto.Query{} = query) do
    array_get(query, [:select])
    |> case do
      [] -> false
      _ -> true
    end
  end

  def query_contains_loadable_fields?(_) do
    false
  end

  def update(conn, params) do
    create_or_update(conn, params)
  end

  def create(conn, params) do
    create_or_update(conn, params)
  end

  defp create_or_update(conn, %{"table" => table, "rowdata" => rowdata} = params) do
    response =
      apply(get_module_name(table), :insert_or_update, [rowdata, params])
      |> MwHelpers.make_jason_friendly()

    json(conn, %{payload: response})
  end

  def delete(conn, %{"table" => table, "id" => id} = params) do
    response =
      apply(get_module_name(table), :delete, [id, params])
      |> MwHelpers.make_jason_friendly()

    json(conn, %{payload: response})
  end

  def get_rows(conn, params) do
    # params |>MwError.die(label: "mwuits-debug 2019-02-24_12:05 ")

    index(conn, params)
  end

  def paste(conn, %{"table" => table, "id" => id} = params) do
    response =
      apply(get_module_name(table), :paste, [id, params])
      |> MwHelpers.make_jason_friendly()

    json(conn, %{payload: response})
  end
end
