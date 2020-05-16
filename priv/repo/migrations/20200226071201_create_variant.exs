defmodule Kandires.Repo.Migrations.CreateVariant do
  use Ecto.Migration

  def change do
    create table(:variant) do
      add(:variant_title, :string)
      add(:vendor_code, :string)
      add(:source_price, :decimal)
      add(:source_type, :string)
      add(:prod_id, references(:prod))
      add(:upload_id, references(:upload))

      timestamps()
    end

    create index(:variant, [:source_type])
    create index(:variant, [:vendor_code])
  end
end
