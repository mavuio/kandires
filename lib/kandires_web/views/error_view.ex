defmodule KandiresWeb.ErrorView do
  use KandiresWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".

  def render("503.json", params) do
    e = Map.get(params, :reason)

    msg = MwError.full_message(e)
    %{errors: [msg]}
  end

  def render("500.json", params) do
    e = Map.get(params, :reason)

    msg = MwError.full_message(e)
    %{errors: [msg]}
  end

  def render("422.json", params) do
    e = Map.get(params, :reason)

    msg = MwError.full_message(e)
    %{errors: [msg]}
  end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
