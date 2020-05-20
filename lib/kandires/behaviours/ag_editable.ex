defmodule Kandires.Behaviours.AgEditable do
  @moduledoc false

  @callback get_record_query_for_controller(%{}) :: %Ecto.Query{}
  @callback insert_or_update(%{}, %{}) :: any
  @callback delete(any, %{}) :: any
end
