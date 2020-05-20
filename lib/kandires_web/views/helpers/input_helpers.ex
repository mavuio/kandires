defmodule KandiresWeb.InputHelpers do
  use Phoenix.HTML

  def input(form, field, opts \\ []) do
    type = Phoenix.HTML.Form.input_type(form, field)

    wrapper_opts = [class: "form-group"]
    label_opts = [class: "control-label"]

    # input_opts = [class: "form-control"]

    input_opts =
      put_in(
        opts[:class],
        String.trim("form-control #{input_state_class(form, field)} #{opts[:class]}")
      )

    content_tag :div, wrapper_opts do
      label = label(form, field, humanize(field), label_opts)
      input = apply(Phoenix.HTML.Form, type, [form, field, input_opts])
      error = KandiresWeb.ErrorHelpers.error_tag(form, field)
      [label, input, error || ""]
    end
  end

  def input_state_class(form, field) do
    cond do
      # The form was not yet submitted
      !form.source.action ->
        ""

      form.errors[field] ->
        "is-invalid"

      true ->
        "is-valid"
    end
  end
end
