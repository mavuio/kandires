defmodule Kandires.UploadC do
  @moduledoc false
  alias Kandires.Upload
  alias Kandires.Repo
  alias Kandires.CsvImporter

  import Ecto.Query
  import MwHelpers

  def start_state_agent(initial_value \\ {"n/a", nil}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_state do
    Agent.get(__MODULE__, & &1)
  end

  def set_state(state) do
    Agent.update(__MODULE__, fn _ -> state end)
  end

  def create_upload_from_plug_upload(type, %Plug.Upload{
        filename: filename,
        path: tmp_path,
        content_type: content_type
      })
      when is_binary(type) do
    hash =
      File.stream!(tmp_path, [], 2048)
      |> Upload.sha256()

    Repo.transaction(fn ->
      with {:ok, %File.Stat{size: size}} <- File.stat(tmp_path),
           {:ok, upload} <-
             %Upload{}
             |> Upload.changeset(%{
               filename: filename,
               content_type: content_type,
               hash: hash,
               size: size,
               type: type
             })
             |> Repo.insert(),
           :ok <-
             File.cp(
               tmp_path,
               Upload.local_path(upload.id, upload.type, filename)
               |> IO.inspect(label: "mwuits-debug 2020-01-13_17:41 ")
             ) do
        {:ok, upload}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)

    # upload creation logic
  end

  def get_upload(record_or_id) do
    case record_or_id do
      %Upload{} = upload -> upload
      id -> Repo.get!(Upload, MwHelpers.to_int(id))
    end
  end

  def process_upload(record_or_id) do
    upload = get_upload(record_or_id)

    CsvImporter.import(upload)
  end

  def get_record_query_for_controller(%{"dataview" => "list_all"} = params) do
    type = array_get(params, "type")

    Upload
    |> select([r], %{
      id: r.id,
      filename: r.filename,
      path: "__generate_path",
      size: r.size,
      type: r.type,
      updated_at: r.updated_at,
      inserted_at: r.inserted_at
    })
    |> pipe_when(
      type,
      where([r], r.type == type(^type, :string))
    )
    |> order_by([r], desc: r.id)
  end

  def generate_path(rec) do
    Upload.local_path(rec.id, rec.type, rec.filename)
  end
end
