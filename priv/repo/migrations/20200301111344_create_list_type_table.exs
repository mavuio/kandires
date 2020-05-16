defmodule Kandires.Repo.Migrations.CreateListTypeTable do
  use Ecto.Migration

  def change do
    create table(:list_type) do
      add(:key, :string)
      add(:note, :string)
      add(:ex_rate, :decimal)
      add(:price1, :decimal)
      add(:price2, :decimal)
      add(:price3, :decimal)
      add(:price4, :decimal)
      add(:price1_vat, :boolean)
      add(:price2_vat, :boolean)
      add(:price3_vat, :boolean)
      add(:price4_vat, :boolean)
      timestamps()
    end

    create unique_index(:list_type, [:key])
  end
end
