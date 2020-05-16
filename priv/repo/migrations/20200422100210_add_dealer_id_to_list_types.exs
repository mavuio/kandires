defmodule Kandires.Repo.Migrations.AddDealerIdToListTypes do
  use Ecto.Migration

  def change do
    alter table(:list_type) do
      add(:dealer_id, references(:dealers))
    end
  end
end
