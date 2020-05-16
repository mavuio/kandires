defmodule Kandires.Category do
  use Ecto.Schema
  # use Decoratex.Schema
  import Ecto.Changeset, warn: false
  @derive {Jason.Encoder, except: [:__meta__]}
  use Ancestry, repo: Kandires.Repo

  # decorations do
  #   decorate_field(:einzelmenge, :decimal, &SoldHelper.get_einzelmenge/2, "12")
  # end

  schema "category" do
    field(:title, :string)
    field(:ancestry, :string)

    timestamps()
  end

  use Accessible

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      [
        :title,
        :ancestry
      ]
    )
  end
end
