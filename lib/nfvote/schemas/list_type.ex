defmodule Kandires.ListType do
  use Ecto.Schema
  import Ecto.Changeset, warn: false
  alias Kandires.Dealer
  @derive {Jason.Encoder, except: [:__meta__]}

  schema "list_type" do
    field(:key, :string)
    field(:note, :string)
    field(:ex_rate, :decimal)
    field(:vat_incl, :boolean)
    field(:price1, :decimal)
    field(:price2, :decimal)
    field(:price3, :decimal)
    field(:price4, :decimal)
    belongs_to(:dealer, Dealer)

    timestamps()
  end

  use Accessible

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      [
        :key,
        :note,
        :ex_rate,
        :vat_incl,
        :price1,
        :price2,
        :price3,
        :price4,
        :dealer_id
      ]
    )
  end
end
