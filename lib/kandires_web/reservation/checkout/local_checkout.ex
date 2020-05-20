defmodule KandiresWeb.Reservation.LocalCheckout do
  @moduledoc false

  # alias Kandis.VisitorSession
  alias KandiresWeb.FrontendHelpers, warn: false

  import Kandis.KdHelpers, warn: false
  import KandiresWeb.MyHelpers, warn: false

  @all_steps ~w(choose data)

  def get_steps(_context) do
    @all_steps
  end

  def get_next_step(current_step, context) when is_binary(current_step) do
    steps = get_steps(context)
    idx = Enum.find_index(steps, &(&1 == current_step))

    cond do
      idx >= length(steps) - 1 -> nil
      true -> steps |> Enum.at(idx + 1)
    end
  end

  def get_prev_step(current_step, context) when is_binary(current_step) do
    steps = get_steps(context)

    Enum.find_index(steps, &(&1 == current_step))
    |> case do
      0 ->
        nil

      idx ->
        steps |> Enum.at(idx - 1)
    end
  end

  def get_next_step_link(context, current_step) when is_map(context) do
    current_step
    |> get_next_step(context)
    |> FrontendHelpers.link_for_step(context)
  end

  def get_prev_step_link(context, current_step) do
    current_step
    |> get_prev_step(context)
    |> FrontendHelpers.link_for_step(context)
  end
end
