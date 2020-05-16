defmodule KandiresWeb.LayoutView do
  use KandiresWeb, :view
  import KandiresWeb.FrontendHelpers, warn: false

  def get_page_title(conn) do
    if conn.assigns[:page_title] do
      "#{conn.assigns[:page_title]} - Kandires"
    else
      "Kandires"
    end
  end
end
