defmodule Kandires.Repo.Migrations.CreateCategoryTable do
  use Ecto.Migration

  def change do
    create table(:category) do
      add(:title, :string)
      add(:ancestry, :string)
      timestamps()
    end

    create index(:category, [:ancestry])
  end
end
