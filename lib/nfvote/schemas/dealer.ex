defmodule Kandires.Dealer do
  alias Kandires.ListType
  use Ecto.Schema
  import Ecto.Changeset, warn: false
  @derive {Jason.Encoder, except: [:__meta__]}

  schema "dealers" do
    field(:title, :string)
    has_many(:list_types, ListType)

    timestamps()
  end

  use Accessible

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      [
        :title
      ]
    )
  end
end
