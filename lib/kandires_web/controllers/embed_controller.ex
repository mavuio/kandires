defmodule KandiresWeb.EmbedController do
  use KandiresWeb, :controller

  def index(conn, params) do
    step(conn, params |> Map.put("step", "choose"))
  end

  def step(conn, params) do
    module_name = get_module_name(params["step"])

    params |> IO.inspect(label: "mwuits-debug 2020-05-20_07:43 ")
    conn = put_layout(conn, false)

    live_render(conn, module_name,
      session:
        params
        |> Kandis.KdHelpers.convert_keys([:vid], &to_string/1)
        |> Kandis.KdHelpers.drop_keys_by_type(:atom)
    )
  end

  def get_module_name(step) do
    String.to_atom(
      "Elixir.KandiresWeb.Reservation.Steps" <>
        "." <> Macro.camelize("reservation_#{step}")
    )
  end
end
