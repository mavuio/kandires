defmodule KandiresWeb.ProdListLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(KandiresWeb.PageView, "prod_list_live.html", assigns)
  end

  def mount(_params, session, socket) do
    {:ok, assign(socket, products: session["products"], current_user: session["current_user"])}
  end
end
