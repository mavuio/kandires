defmodule Kandires.Prod do
  use Ecto.Schema
  # use Decoratex.Schema
  import Ecto.Changeset, warn: false
  alias Kandires.Upload
  alias Kandires.Variant
  @derive {Jason.Encoder, except: [:__meta__]}
  # decorations do
  #   decorate_field(:einzelmenge, :decimal, &SoldHelper.get_einzelmenge/2, "12")
  # end

  schema "prod" do
    field(:title, :string)
    field(:text, :string)
    field(:path, :string)
    field(:sku, :string)
    field(:brand, :string)
    field(:url, :string)
    field(:img_urls, :string)
    field(:source_type, :string)
    has_many(:variants, Variant)
    belongs_to(:upload, Upload)
    timestamps()
  end

  use Accessible

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      [
        :title,
        :text,
        :path,
        :sku,
        :brand,
        :url,
        :img_urls,
        :source_type,
        :upload_id
      ]
    )
  end
end
