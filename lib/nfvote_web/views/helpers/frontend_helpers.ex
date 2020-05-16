defmodule KandiresWeb.FrontendHelpers do
  use Phoenix.HTML

  # import MwHelpers

  def body_classes(conn) do
    [
      "c-#{
        Phoenix.Controller.controller_module(conn) |> Phoenix.Naming.resource_name("Controller")
      }",
      "pa-#{Phoenix.Controller.action_name(conn)}",
      "use-vat-#{get_user_val_from_conn(conn, :vat_type)}"
    ]
    |> Enum.join(" ")
  end

  def get_user_val_from_conn(conn, key, default \\ nil) do
    Kandis.KdHelpers.array_get(conn.assigns, [:current_user, key], default)
  end

  def format_price([]) do
    format_price(nil)
  end

  def format_price(price, precision \\ 2) do
    res =
      price
      |> Number.Delimit.number_to_delimited(precision: precision, delimiter: ".", separator: ",")

    if Kandis.KdHelpers.present?(price) do
      # nbsp:
      "#{res}"
    else
      ""
    end
  end

  def wrap_at_dash(nil) do
    nil
  end

  def wrap_at_dash(str) do
    str |> String.replace("-", "<br>", global: false)
  end

  defdelegate trans(lang_or_params, txt_en, txt_de \\ nil), to: KandiresWeb.MyHelpers

  defdelegate t(lang_or_params, key), to: KandiresWeb.MyHelpers

  defdelegate lang_from_params(lang_or_params), to: KandiresWeb.MyHelpers

  defdelegate local_date(utc_date), to: KandiresWeb.MyHelpers
  defdelegate format_date(utc_date), to: KandiresWeb.MyHelpers

  def tableify(str) when is_binary(str) do
    str
    |> String.split("\n")
    |> Enum.map(&render_line/1)
    |> (fn a -> "<table class='table table-striped'>#{a}</table>" end).()
    |> Phoenix.HTML.raw()
  end

  def render_line(str) when is_binary(str) do
    str
    |> String.split("|")
    |> Enum.map(fn a -> "<td>#{a}</td>" end)
    |> Enum.join()
    |> case do
      "<td></td>" -> ""
      line -> "<tr>#{line}</tr>"
    end
  end
end
