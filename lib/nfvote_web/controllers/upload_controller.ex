defmodule KandiresWeb.UploadController do
  use KandiresWeb, :controller
  alias Kandires.UploadC
  alias Kandires.ListTypeC

  plug(:put_layout, {KandiresWeb.LayoutView, "backend.html"})

  def get_types() do
    # ~w(deekay_steel deekay_plumbing_valves deekay_galvanized_fittings)
    ListTypeC.get_type_keys()
  end

  def new(conn, %{"type" => type} = _params) do
    render(conn, "upload_new.html", type: type, types: get_types())
  end

  def index(conn, params) do
    render(conn, "upload_list.html", type: params["type"], types: get_types())
  end

  def process_upload(conn, %{"id" => id} = params) do
    upload = UploadC.get_upload(id)
    render(conn, "process_upload.html", type: params["type"], upload: upload)
  end

  def process_upload_run(conn, %{"id" => id} = params) do
    upload = UploadC.get_upload(id)
    res = UploadC.process_upload(upload)
    render(conn, "process_upload_run.html", type: params["type"], upload: upload, res: res)
  end

  def create(conn, %{"upload" => %Plug.Upload{} = upload, "type" => type}) do
    case UploadC.create_upload_from_plug_upload(type, upload) do
      {:ok, _upload} ->
        conn = put_flash(conn, :info, "file uploaded correctly")
        redirect(conn, to: Routes.upload_path(conn, :index, type))

      {:error, reason} ->
        conn = put_flash(conn, :error, "error upload file: #{inspect(reason)}")
        render(conn, "new.html")
    end
  end

  def create(conn, _) do
    conn = put_flash(conn, :error, "no file uploaded")
    render(conn, "new.html")
  end
end
