defmodule KandiresWeb.MemberLogin do
  @moduledoc false

  def redirect_if_not_logged_in(conn, vid, %{} = params, [] = opts \\ []) do
    if vid do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(
        :warning,
        opts[:msg] || "Bitte melde dich an"
      )
      # |> Phoenix.Controller.redirect(to: )
      |> Plug.Conn.halt()
    end
  end
end
