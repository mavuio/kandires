defmodule KandiresWeb.Shop.Countries do
  @moduledoc false

  alias KandiresWeb.FrontendHelpers

  def get_country_name(code) do
    case Countries.get(code) do
      nil -> ""
      c -> c.name
    end
  end
end
