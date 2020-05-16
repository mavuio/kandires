defmodule Kandires.Member do
  use Ecto.Schema

  import Ecto.Changeset, warn: false
  @derive {Jason.Encoder, except: [:__meta__]}

  schema "members" do
    field(:fullname, :string)
    field(:mglnr, :string)
    field(:gender, :string)
  end

  use Accessible
end
