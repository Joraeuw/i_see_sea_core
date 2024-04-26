defmodule ISeeSea.Repo.Migrations.CreateBaseReportTable do
  use Ecto.Migration

  def change do
    create table("base_reports") do
      add :name, :string, null: false
      add :report_type, :string, null: false
      add :user_id, references(:users), null: false
      add :report_date, :utc_datetime, null: false
      add :longitude, :float, null: false
      add :latitude, :float, null: false
      add :comment, :string, null: true

      timestamps()
    end

    create table("jellyfish_reports", primary_key: false) do
      add :report_id, references(:base_reports), null: false
      add :quantity, :integer, null: false
      add :species, :string, null: true, default: ""
    end

    execute "ALTER TABLE jellyfish_reports ADD PRIMARY KEY (report_id);"

    create table("pollution_types") do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:pollution_types, [:name])

    create table("pollution_reports", primary_key: false) do
      add :report_id, references(:base_reports), null: false
    end

    execute "ALTER TABLE pollution_reports ADD PRIMARY KEY (report_id);"

    create table("pollution_reports_pollution_types") do
      add :pollution_report_id, references(:pollution_reports, column: :report_id), null: false
      add :pollution_type_id, references(:pollution_types), null: false

      timestamps()
    end

    create table("fog_types") do
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:fog_types, [:name])

    create table("wind_types") do
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:wind_types, [:name])

    create table("sea_swell_types") do
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:sea_swell_types, [:name])

    create table("meteorological_reports", primary_key: false) do
      add :report_id, references(:base_reports), null: false
      add :fog_type_id, references(:fog_types), null: false
      add :wind_type_id, references(:wind_types), null: false
      add :sea_swell_type_id, references(:sea_swell_types), null: false
    end

    execute "ALTER TABLE meteorological_reports ADD PRIMARY KEY (report_id);"

    create table("atypical_activity_reports", primary_key: false) do
      add :report_id, references(:base_reports), null: false
    end

    execute "ALTER TABLE atypical_activity_reports ADD PRIMARY KEY (report_id);"

    create unique_index(:jellyfish_reports, [:report_id])
    create unique_index(:pollution_reports, [:report_id])
    create unique_index(:meteorological_reports, [:report_id])
    create unique_index(:atypical_activity_reports, [:report_id])
  end
end
