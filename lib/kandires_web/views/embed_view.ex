defmodule KandiresWeb.EmbedView do
  use KandiresWeb, :view
  import KandiresWeb.FrontendHelpers, warn: false

  def cors_hosts(_conn) do
    [
      "https://kandires.werkzeugh.at.test",
      "https://nfvote.werkzeugh.at.test",
      "https://www.werkzeugh.at"
    ]
  end
end
