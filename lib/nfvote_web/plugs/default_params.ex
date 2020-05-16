defmodule KandiresWeb.Plugs.DefaultParams do
  @moduledoc "Get public IP address of request from x-forwarded-for header"
  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    # add vid
    # do also in mount_user() for live-view
    # Plug.Conn.get_session(conn) |> Kandis.KdError.die(label: "DEFAULTPARAMS ")

    vid =
      case conn.assigns.current_user do
        %{id: id} -> "user.#{id}"
        _ -> Plug.Conn.get_session(conn, :anon_userid)
      end
      |> IO.inspect(label: "VID")

    conn =
      conn
      |> Plug.Conn.assign(:vid, vid)

    %{assigns: conn.assigns, params: conn.params}

    conn
  end
end
