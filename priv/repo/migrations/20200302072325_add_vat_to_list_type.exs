defmodule Kandires.Repo.Migrations.AddVatToListType do
  use Ecto.Migration

  def change do
    alter table(:list_type) do
      add :vat_incl, :boolean
      add :ancestry, :string
    end
  end
end
