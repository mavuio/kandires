defmodule Kandires.Variant do
  use Ecto.Schema
  # use Decoratex.Schema
  import Ecto.Changeset, warn: false
  alias Kandires.Prod
  alias Kandires.Upload
  alias Kandires.ListType
  @derive {Jason.Encoder, except: [:__meta__]}

  # decorations do
  #   decorate_field(:einzelmenge, :decimal, &SoldHelper.get_einzelmenge/2, "12")
  # end

  schema "variant" do
    field(:variant_title, :string)
    field(:vendor_code, :string)
    field(:source_price, :decimal)
    field(:source_type, :string)
    # field(:prod_id, references(:prod))
    belongs_to(:prod, Prod)
    belongs_to(:upload, Upload)

    timestamps()
  end

  use Accessible

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      [
        :variant_title,
        :vendor_code,
        :source_price,
        :source_type,
        :prod_id,
        :upload_id
      ]
    )
  end
end
