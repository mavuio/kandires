defmodule KandiresWeb.BulmaInputHelpers do
  use Phoenix.HTML

  import Kandis.KdHelpers, warn: false

  def bulma_input(form, field, opts \\ []) do
    type = Phoenix.HTML.Form.input_type(form, field)

    wrapper_opts = [class: "bu-field"]
    control_opts = [class: "bu-control"]
    label_opts = [class: "bu-label"]

    # input_opts = [class: "form-control"]

    input_opts =
      put_in(
        opts[:class],
        String.trim("bu-input #{input_state_class(form, field)} #{opts[:class]}")
      )

    content_tag :div, wrapper_opts do
      label = label(form, field, opts[:label] || humanize(field), label_opts)
      input = apply(Phoenix.HTML.Form, type, [form, field, input_opts])

      control = content_tag(:div, input, control_opts)

      error = KandiresWeb.BulmaErrorHelpers.error_tag(form, field) |> Kandis.KdHelpers.if_nil("")
      [label, control, error]
    end
  end

  def input_state_class(%{source: source} = form, field) when is_map(source) do
    cond do
      # The form was not yet submitted
      !form.source.action ->
        ""

      form.errors[field] ->
        "bu-is-danger"

      # ""

      true ->
        # "is-valid"
        ""
    end
  end

  def input_state_class(_form, _field), do: ""
end
