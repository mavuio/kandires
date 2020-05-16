defmodule Kandires.CsvImporter do
  @moduledoc false
  alias Kandires.UploadC
  alias Kandires.Repo
  alias Kandires.Variant
  alias Kandires.Prod
  alias Kandires.ProdC
  alias Kandires.Upload
  import Ecto.Query, warn: false
  import MwHelpers, warn: false

  def start_state_agent(initial_value \\ %{}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_state(field) do
    val = Agent.get(__MODULE__, & &1)
    val[field]
  end

  def set_state(field, value) do
    Agent.update(__MODULE__, fn state -> state |> Map.put(field, value) end)
  end

  def import(upload_or_id) do
    start_state_agent()

    upload = UploadC.get_upload(upload_or_id)
    type = upload.type
    filename_valid_for_type?(upload.filename, type)

    delete_records_for_type(type)

    res =
      upload
      |> Upload.local_path()
      |> File.stream!(encoding: :utf8, trim_bom: true)
      # |> Enum.take(1)
      |> handle_lines(upload, type)
      |> Enum.take(10000)

    # |> Enum.map(&Tuple.to_list/1)

    # StockC.recalculate_stock()
    res
  end

  def handle_lines(
        line_stream,
        %Upload{} = upload,
        type
      ) do
    _stream =
      line_stream
      |> Stream.map(&ignore_bom/1)
      |> CSV.decode!(preprocessor: :none, strip_fields: true, headers: true)
      |> Stream.chunk_while(
        _acc = {_prod = nil, _variant_lines = []},
        &chunk_prod/2,
        &chunk_prod_after/1
      )
      |> Stream.map(&import_product_and_variants(&1, upload))
      |> Enum.take(2000)

    # case missing_fields(fieldnames, table_type) do
    #   [] ->
    #     :ok

    #   fields ->
    #     fields |> MwError.die(label: "einige Felder fehlen in Liste")
    # end

    # default_record = %{
    #   day: day,
    #   upload_id: upload.id
    # }

    # rowstream
    # |> Enum.take(1000)
    # |> (fn a ->
    #       length(a) |> IO.inspect(label: "NUM LINES FOUND: ")
    #       a
    #     end).()
    # |> Enum.map(& &1)

    # |> Enum.map(&import_product(&1, fieldnames, default_record, table_type))

    # #   "FIN #{year}"
    # # end
  end

  def ignore_bom(line) do
    if String.starts_with?(line, "\ufeff") do
      String.replace(line, "\ufeff", "")
    else
      line
    end
  end

  def chunk_prod(el, {prod, variants} = _acc) do
    if(present?(el["title"])) do
      if present?(prod) do
        {:cont, %{prod: prod, variants: Enum.reverse(variants)}, {el, [el]}}
      else
        {:cont, {el, [el]}}
      end
    else
      prod =
        prod
        |> pipe_when(
          present?(el["img_urls"]),
          (fn prod ->
             prod |> Map.put("img_urls", prod["img_urls"] <> "," <> el["img_urls"])
           end).()
        )

      {:cont, {prod, [el | variants]}}
    end
  end

  def chunk_prod_after({prod, variants} = _acc) do
    {:cont, %{prod: prod, variants: Enum.reverse(variants)}, nil}
  end

  def get_field_names_from_header(header) do
    header
    |> Enum.map(fn fieldname -> Recase.to_snake(fieldname || "") end)
    |> Enum.map(fn str ->
      Regex.replace(~r/[^a-z0-9_]/, str, "")
      |> String.trim("_")
      # |> rename_header()
      |> case do
        "" -> "__skip"
        a -> a
      end
    end)
    |> Enum.filter(& &1)
  end

  def import_product_and_variants(%{prod: prod, variants: variants}, upload) do
    prod_rec = import_prod(prod, upload)

    variants
    |> Enum.map(&import_variant(&1, prod_rec, upload))

    "#{prod_rec.title} (#{length(variants)})"
  end

  def import_prod(prod, upload) do
    prod =
      prod
      |> fill_empty_levels()

    prod =
      prod
      |> Map.put("source_type", upload.type)
      |> Map.put("upload_id", upload.id)
      |> Map.put("path", get_path_for_prod(prod))

    save_levels(prod)

    prod =
      %Prod{}
      |> Prod.changeset(prod)
      |> Repo.insert!()

    ProdC.cache_product_images(prod)
    prod
  end

  def save_levels(prod) do
    ~w(level1 level2 level3)
    |> Enum.map(fn field ->
      set_state(
        field,
        prod[field]
      )
    end)
  end

  def fill_empty_levels(prod) do
    ~w(level1 level2 level3)
    |> Enum.reduce(prod, fn field, prod ->
      if empty?(prod[field]) do
        Map.put(prod, field, get_state(field))
      else
        prod
      end
    end)
  end

  def import_variant(variant, prod_rec, upload) do
    variant =
      variant
      |> Map.put("source_type", upload.type)
      |> Map.put("upload_id", upload.id)
      |> Map.put("prod_id", prod_rec.id)
      |> Map.put("source_price", parse_decimal(variant["price"]))

    %Variant{}
    |> Variant.changeset(variant)
    |> Repo.insert!()
  end

  def parse_decimal(str) when is_binary(str) do
    str
    |> String.replace(",", "")
    |> str_to_dec()
  end

  def parse_decimal(nil) do
    nil
  end

  def get_path_for_prod(prod) do
    path =
      prod
      |> Map.to_list()
      |> Enum.filter(fn {key, _val} -> String.starts_with?(key, "level") end)
      |> Enum.map(fn {_key, val} -> val end)
      |> Enum.join("/")
      |> String.trim("/")

    "/#{path}"
  end

  def delete_records_for_type(type) do
    get_variant_records_for_type(type)
    |> Repo.delete_all()

    get_prod_records_for_type(type)
    |> Repo.delete_all()
  end

  def get_prod_records_for_type(type) do
    Prod
    |> where([s], s.source_type == ^type)
  end

  def get_variant_records_for_type(type) do
    Variant
    |> where([s], s.source_type == ^type)
  end

  def filename_valid_for_type?(filename, type) do
    String.contains?(filename, type)
  end
end
