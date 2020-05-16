defmodule Kandires.Repo.Migrations.AddPriceToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:pricefield, :string, null: true)
      add(:name, :string, null: true)
      add(:company, :string, null: true)
      add(:address, :string, null: true)
      add(:phone, :string, null: true)
      add(:tpin, :string, null: true)
    end
  end
end
