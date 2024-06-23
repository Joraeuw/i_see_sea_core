defmodule ISeeSea.Repo.Migrations.AddStormType do
  use Ecto.Migration

  alias ISeeSea.Constants
  alias ISeeSea.DB.Models.StormType

  def change do
    create table("storm_types", primary_key: false) do
      add :name, :string, null: false, primary_key: true
      timestamps()
    end

    alter table("atypical_activity_reports") do
      add :storm_type_id, references(:storm_types, column: :name, type: :string), null: false
    end

    create unique_index(:storm_types, [:name])

    flush()

    for type <- Constants.StormType.values() do
      {:ok, _} = StormType.create(%{name: type})
    end
  end
end
