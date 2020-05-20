defmodule KandiresWeb.VueCliHelper do
  @root_dir File.cwd!()
  @static_dir Path.join(~w(#{@root_dir} priv static))

  # @cache_file Path.join(~w(#{@tmp_dir} scc_api.dat))

  import KandiresWeb.MyHelpers, warn: false
  import Kandis.KdHelpers

  def is_hot(conn) do
    case array_get(conn.params, "hot") do
      "1" ->
        true

      _ ->
        case System.get_env("HOT") do
          "1" -> true
          _ -> false
        end
    end
  end

  def vue_cli(conn, path, prefix \\ "/") do
    if is_hot(conn) do
      get_hot_url(path)
    else
      case parse_path(path) do
        {:ok, {url_dir, file_dir, file_name}} ->
          Path.join([
            prefix,
            url_dir,
            get_files_in_dir(file_dir)
            |> array_get(file_name)
          ])

        {:error, reason} ->
          reason
      end
    end
  end

  defp get_hot_url(url) do
    Path.join([
      "https://localhost:#{hot_port()}",
      Path.dirname(Path.dirname(url)),
      Path.basename(url)
    ])
  end

  def hot_port() do
    Application.get_env(:sccapi_web, VueCliHelper)[:hot_port] || "8080"
  end

  def parse_path(path) do
    {url_dir, file_dir, file_name} =
      case Regex.run(~r<(/engine/.*?)([^/]+)$>, path) do
        [_m0 | [m1 | [m2 | []]]] -> {m1, Path.join(@static_dir, m1), m2}
        _ -> {nil, nil, nil}
      end

    case(get_files_in_dir(file_dir)) do
      %{} -> {:ok, {url_dir, file_dir, file_name}}
      nil -> {:error, "not_found"}
    end
  end

  def get_files_in_dir(dir) do
    dir
    |> File.ls()
    |> case do
      {:ok, files} ->
        files
        |> Enum.map(fn a ->
          String.split(a, ".")
          |> case do
            [base | [_hash | rest]] = parts when length(parts) >= 2 and byte_size(base) > 2 ->
              {Enum.join([base | rest], "."), a}

            _ ->
              nil
          end
        end)
        |> Enum.filter(&(not is_nil(&1)))
        |> Map.new()

      _ ->
        nil
    end
  end
end
