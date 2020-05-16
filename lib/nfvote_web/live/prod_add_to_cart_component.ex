defmodule ProdAddToCartComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(KandiresWeb.PageView, "prod_add_to_cart_component.html", assigns)
  end

  def mount(socket) do
    {:ok, assign(socket, open: false)}
  end

  def handle_event("toggle", _, socket) do
    {:noreply, assign(socket, open: not socket.assigns.open)}
  end
end
