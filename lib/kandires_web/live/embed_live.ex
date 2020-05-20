defmodule KandiresWeb.EmbedLive do
  use Phoenix.LiveView, layout: {KandiresWeb.LayoutView, "embed.html"}

  def mount(_params, session, socket) do
    session
    |> IO.inspect(
      label: "mwuits-debug 2020-05-16_21:37 MOUNT (session) conn: #{connected?(socket)}"
    )

    {:ok,
     assign(socket,
       conn: socket,
       open: false,
       products: session["products"],
       current_user: session["current_user"]
     )}
  end

  def handle_event(event, msg, socket) do
    {event, msg} |> IO.inspect(label: "mwuits-debug 2020-05-16_21:39 HANDLE EVENT")
    {:noreply, assign(socket, open: not socket.assigns.open)}
  end
end
