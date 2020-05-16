defmodule Kandires.Repo.Migrations.CreateDealersTable do
  use Ecto.Migration

  def change do
    create table(:dealers) do
      add(:title, :string)
      timestamps()
    end
  end
end
