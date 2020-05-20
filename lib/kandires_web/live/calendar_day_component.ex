defmodule KandiresWeb.CalendarDayComponent do
  use Phoenix.LiveComponent
  use Timex

  def render(assigns) do
    assigns = Map.put(assigns, :day_class, day_class(assigns))

    ~L"""
    <td phx-click="pick-date" phx-target="<%= @target %>" phx-value-date="<%= Timex.format!(@day, "%Y-%m-%d", :strftime) %>" class="<%= @day_class %>">
      <%= Timex.format!(@day, "%d", :strftime) %>
    </td>
    """
  end

  defp day_class(assigns) do
    cond do
      today?(assigns) ->
        "day today"

      current_date?(assigns) ->
        "day current_date"

      past?(assigns) ->
        "day past"

      other_month?(assigns) ->
        "day other_month"

      true ->
        "day"
    end
  end

  defp current_date?(assigns) do
    (Map.take(assigns.day, [:year, :month, :day]) ==
       Map.take(assigns.current_date, [:year, :month, :day]))
    |> IO.inspect(
      label: "mwuits-debug 2020-05-19_00:13 #{assigns.day}==#{assigns.current_date}curr"
    )
  end

  defp today?(assigns) do
    Map.take(assigns.day, [:year, :month, :day]) ==
      Map.take(Timex.now(), [:year, :month, :day])
  end

  defp past?(assigns) do
    Timex.before?(assigns.day, Timex.now())
  end

  defp other_month?(assigns) do
    Map.take(assigns.day, [:year, :month]) != Map.take(assigns.current_month, [:year, :month])
  end
end
