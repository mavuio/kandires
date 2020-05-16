defmodule Kandires.Repo.Migrations.AddVatTypeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :vat_type, :string, default: "incl"
    end
  end
end
