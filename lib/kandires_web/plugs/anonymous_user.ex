defmodule KandiresWeb.Plugs.AnonymousUser do
  @moduledoc "Get public IP address of request from x-forwarded-for header"
  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    anon_userid = Plug.Conn.get_session(conn, :anon_userid)

    if is_nil(anon_userid) do
      Plug.Conn.put_session(conn, :anon_userid, get_anon_user_id())
    else
      conn
    end
  end

  def get_anon_user_id(), do: Pow.UUID.generate()
end
