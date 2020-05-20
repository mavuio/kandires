defmodule KandiresWeb.CalendarComponent do
  use Timex

  use Phoenix.LiveComponent

  @week_start_at :mon

  def mount(socket) do
    current_date = Timex.now()

    assigns = [
      conn: socket,
      current_date: current_date,
      current_month: current_date,
      day_names: day_names(@week_start_at),
      week_rows: week_rows(current_date)
    ]

    # |> Kandis.KdError.die(label: "mwuits-debug 2020-05-17_10:57 ")

    {:ok, assign(socket, assigns)}
  end

  # defp day_names(:sun), do: [7, 1, 2, 3, 4, 5, 6] |> Enum.map(&Timex.day_shortname/1)
  defp day_names(_), do: [1, 2, 3, 4, 5, 6, 7] |> Enum.map(&Timex.day_shortname/1)

  defp week_rows(current_date) do
    first =
      current_date
      |> Timex.beginning_of_month()
      |> Timex.beginning_of_week(@week_start_at)

    last =
      current_date
      |> Timex.end_of_month()
      |> Timex.end_of_week(@week_start_at)

    Interval.new(from: first, until: last)
    |> Enum.map(& &1)
    |> Enum.chunk_every(7)
  end

  def handle_event("prev-month", _, socket) do
    current_month = Timex.shift(socket.assigns.current_month, months: -1)

    assigns = [
      current_month: current_month,
      week_rows: week_rows(current_month)
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("next-month", _, socket) do
    current_month = Timex.shift(socket.assigns.current_month, months: 1)

    assigns = [
      current_month: current_month,
      week_rows: week_rows(current_month)
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("pick-date", %{"date" => date}, socket) do
    current_date = Timex.parse!(date, "{YYYY}-{0M}-{D}")

    assigns = [
      current_date: current_date
    ]

    {:noreply, assign(socket, assigns)}
  end
end
