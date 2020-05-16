defmodule KandiresWeb.MdcInputHelpers do
  use Phoenix.HTML

  import Kandis.KdHelpers

  def mdc_input(form, field, opts \\ []) do
    type = opts[:type] || Phoenix.HTML.Form.input_type(form, field)

    wrapper_opts = [class: "input-wrapper text-field-container " <> (opts[:class] || "")]
    textfield_opts = [class: "mdc-text-field mdc-text-field--outlined"]

    val = form.params[to_string(field)]

    has_value = Kandis.KdHelpers.present?(val)

    input_opts = [class: "mdc-text-field__input"]

    content_tag :div, wrapper_opts do
      textfield =
        content_tag :label, textfield_opts do
          label =
            content_tag(:span,
              class:
                if has_value do
                  "mdc-notched-outline mdc-notched-outline--notched"
                else
                  "mdc-notched-outline"
                end
            ) do
              [
                content_tag(:span, nil, class: "mdc-notched-outline__leading"),
                content_tag(:span, class: "mdc-notched-outline__notch") do
                  content_tag(:span, opts[:label] || humanize(field),
                    class:
                      if has_value do
                        "mdc-floating-label mdc-floating-label--float-above"
                      else
                        "mdc-floating-label"
                      end
                  )
                end,
                content_tag(:span, nil, class: "mdc-notched-outline__trailing")
              ]
            end

          input =
            case type do
              "select" ->
                Phoenix.HTML.Form.select(
                  form,
                  field,
                  opts[:items],
                  input_opts |> Keyword.drop([:items])
                )

              _ ->
                apply(
                  Phoenix.HTML.Form,
                  type,
                  [form, field, input_opts]
                )
            end

          [input, label]
        end

      error = KandiresWeb.MdcErrorHelpers.error_tag(form, field) |> if_nil("")
      [textfield, error]
    end
  end

  def bs_input(form, field, opts \\ []) do
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
      label = label(form, field, opts[:label] || humanize(field), label_opts)
      input = apply(Phoenix.HTML.Form, type, [form, field, input_opts])
      error = KandiresWeb.MdcErrorHelpers.error_tag(form, field) |> Kandis.KdHelpers.if_nil("")
      [label, input, error]
    end
  end

  def input_state_class(%{source: source} = form, field) when is_map(source) do
    cond do
      # The form was not yet submitted
      !form.source.action ->
        ""

      form.errors[field] ->
        "is-invalid"

      # ""

      true ->
        # "is-valid"
        ""
    end
  end

  def input_state_class(_form, _field), do: ""
end
