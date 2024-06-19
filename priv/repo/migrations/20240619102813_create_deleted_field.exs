defmodule ISeeSea.Repo.Migrations.CreateDeletedField do
  use Ecto.Migration

  def change do
    alter table(:base_reports) do
      add :deleted, :boolean, default: false, null: false
    end

    create index(:base_reports, [:deleted])
  end
end
