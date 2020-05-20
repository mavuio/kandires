defmodule MwHelpers do
  @moduledoc """
    generic helpers by Manfred Wuits
  """

  @doc """
  array_get helper taken from laravel
  """
  def array_get(data, keys, default \\ nil)

  def array_get(%_{} = struct, keys, default) when is_list(keys) do
    ret = Maybe.maybe(struct, keys)

    if ret do
      ret
    else
      default
    end
  end

  def array_get(data, keys, default) when is_list(keys) do
    case get_in(data, keys) do
      nil -> default
      "" -> default
      result -> result
    end
  end

  def array_get(data, key, default) when is_binary(key) or is_atom(key) do
    array_get(data, [key], default)
  end

  defmacro pipe_when(left, condition, fun) do
    quote do
      left = unquote(left)

      if unquote(condition),
        do: left |> unquote(fun),
        else: left
    end
  end

  def struct_from_map(a_map, as: a_struct) do
    # Find the keys within the map
    keys =
      Map.keys(a_struct)
      |> Enum.filter(fn x -> x != :__struct__ end)

    # Process map, checking for both string / atom keys
    processed_map =
      for key <- keys, into: %{} do
        value = Map.get(a_map, key) || Map.get(a_map, to_string(key))
        {key, value}
      end

    processed_map |> IO.inspect(label: "mwuits-debug 2018-08-14_11:07 ")

    # a_struct = Map.merge(a_struct, processed_map)
    a_struct
  end

  def dec_to_str(nil) do
    dec_to_str("0")
  end

  def dec_to_str(string) when is_binary(string) do
    dec_to_str(Decimal.new(string))
  end

  def dec_to_str(decimal) do
    # fix_suffix = fn suf -> suf |> String.trim_trailing("0") end

    # Decimal.set_context(%Decimal.Context{Decimal.get_context() | precision: 5})

    decimal
    |> Decimal.to_string(:normal)

    # |> String.trim_trailing("0")
    # |> (&(&1 <> "0")).()
  end

  def to_int(val) do
    case val do
      val when is_integer(val) ->
        val

      val when is_binary(val) ->
        Integer.parse(val)
        |> case do
          {val, ""} -> val
          _ -> nil
        end

      val when is_float(val) ->
        Kernel.round(val)

      %Decimal{} = val ->
        val |> Decimal.round() |> Decimal.to_integer()

      nil ->
        nil
    end
  end

  #  needs   [{:blankable, "~> 1.0.0"}]

  def present?(term) do
    !Blankable.blank?(term)
  end

  def empty?(term) do
    Blankable.blank?(term)
  end

  def print_sql(queryable, repo, msg \\ "print SQL: ", level \\ :warn) do
    log(
      Ecto.Adapters.SQL.to_sql(:all, repo, queryable)
      |> interpolate_sql(),
      msg,
      level
    )

    queryable
  end

  def interpolate_sql({sql, args}) do
    sql =
      Enum.map(args, fn val -> inspect(val) end)
      |> Enum.map(fn a -> String.replace(a, "\"", "'") end)
      |> Enum.with_index()
      |> Enum.reduce(sql, fn {val, idx}, sql ->
        String.replace(sql, "$#{idx + 1}", val)
      end)
      |> String.split("\n")
      |> Enum.join(" ")

    """

    #{sql};

    """
  end

  def make_jason_friendly(term) do
    case term do
      {:ok, term} -> make_jason_friendly(term)
      term when is_tuple(term) -> Tuple.to_list(term)
      term -> term
    end
  end

  require Logger

  def log(data, msg \\ "", level \\ :debug) do
    Logger.log(
      level,
      msg <> " " <> inspect(data, printable_limit: :infinity, limit: 50, pretty: true)
    )

    data
  end

  def not_nil(var) do
    not is_nil(var)
  end

  def convert_map_to_kwlist(val) when is_map(val) do
    Enum.map(val, fn
      {key, value} when is_binary(key) -> {String.to_existing_atom(key), booleanize(value)}
      {key, value} when is_atom(key) -> {key, booleanize(value)}
    end)
  end

  def convert_map_to_kwlist(val) when is_list(val) do
    val
  end

  def convert_map_to_kwlist(_val) do
    []
  end

  def str_to_dec(""), do: nil
  def str_to_dec(nil), do: nil
  def str_to_dec(%Decimal{} = v), do: v

  def str_to_dec(str) do
    case Decimal.parse(str) do
      :error -> str
      {:ok, dec} -> dec
    end
  end

  def to_date(nil) do
    nil
  end

  def to_date(%Date{} = date) do
    date
  end

  def to_date({y, m, d}) do
    {:ok, date} = Date.new(y |> to_int(), m |> to_int(), d |> to_int())
    date
  end

  def to_date(str) when is_binary(str) do
    # str |> MwError.die(label: "mwuits-debug 2019-12-12_13:27 ")

    nil
    |> case do
      nil ->
        Regex.named_captures(~r/(?<d>\d\d?)\.(?<m>\d\d?)\.(?<y>\d\d\d\d)/, str)
        # p->p
    end
    |> case do
      nil -> Regex.named_captures(~r/(?<y>\d\d\d\d?)[-_](?<m>\d\d?)[-_](?<d>\d\d)/, str)
      p -> p
    end
    |> case do
      %{"d" => d, "m" => m, "y" => y} -> to_date({y, m, d})
      _ -> nil
    end
  end

  def booleanize(val) do
    case val do
      "true" -> true
      "false" -> false
      "1" -> true
      "0" -> false
      1 -> true
      0 -> false
      nil -> false
      "" -> false
      [] -> false
      _ -> val
    end
  end
end
