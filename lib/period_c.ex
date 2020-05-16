defmodule Kandires.PeriodC do
  def get_year_from_period(period) when is_integer(period) do
    get_year_from_period("#{period}")
  end

  def get_year_from_period(period) when is_binary(period) do
    case MwHelpers.to_int(period) do
      year when is_integer(year) and year > 2000 and year < 3000 -> year
      _ -> nil
    end
  end

  def get_default_yearmonth() do
    Date.utc_today()
    |> Date.to_string()
    |> String.slice(0..-4)
  end

  def get_period_type(period) do
    case period do
      year when is_binary(year) ->
        get_year_from_period(year)
        |> case do
          year when is_integer(year) -> {:year, year}
          _ -> nil
        end

      _ ->
        nil
    end
  end

  def get_dateranges_for_interval(interval, period)
      when is_binary(interval) and is_binary(period) do
    case get_period_type(period) do
      {:year, year} ->
        case interval do
          "monthly" -> get_month_ranges_for_year(year)
        end

      _ ->
        []
    end
  end

  def get_month_ranges_for_year(year) when is_integer(year) do
    1..12
    |> Enum.map(&get_date_range_for_month(year, &1))
  end

  def get_date_range_for_month(year, month) when is_integer(year) and is_integer(month) do
    {get_first_date_in_month(year, month), get_last_date_in_month(year, month)}
  end

  def get_first_date_in_month(year, month) when is_integer(year) and is_integer(month) do
    monthstr =
      month
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{year}-#{monthstr}-01"
  end

  def get_last_date_in_month(year, month) when is_integer(year) and is_integer(month) do
    first_date = get_first_date_in_month(year, month)

    day_str =
      first_date
      |> Date.from_iso8601!()
      |> Date.days_in_month()
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    String.replace_trailing(first_date, "01", day_str)

    # date = DateTime.to_date(datetime)
    # last_day_of_previous_month = Date.add(date, date.day * -1)

    # end_of_last_day_on_original_timezone =
    #   last_day_of_previous_month
    #   |> NaiveDateTime.new(~T[23:59:59])
    #   |> DateTime.from_naive(datetime.time_zone)
  end

  def add_days_to_date(date, days) when is_binary(date) and is_binary(days) do
    days =
      case MwHelpers.to_int(days) do
        days -> days
        nil -> 1
      end

    date
    |> Date.from_iso8601!()
    |> Date.add(days)
  end
end
