defmodule Kandires.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add(:fullname, :string, null: false)
      add(:mglnr, :string)
      add(:gender, :string)
      # timestamps()
    end

    create(unique_index(:members, [:mglnr]))
  end
end
