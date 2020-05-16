defmodule Kandires.Repo.Migrations.CreateProd do
  use Ecto.Migration

  def change do
    create table(:prod) do
      add(:title, :string)
      add(:text, :text)
      add(:path, :string)
      add(:sku, :string)
      add(:brand, :string)
      add(:url, :string)
      add(:img_urls, :string, size: 4096)
      add(:source_type, :string)
      add(:upload_id, references(:upload))

      timestamps()
    end

    create index(:prod, [:path])
    create index(:prod, [:source_type])
  end
end
