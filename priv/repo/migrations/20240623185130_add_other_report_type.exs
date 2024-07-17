defmodule ISeeSea.Repo.Migrations.AddOtherReportType do
  use Ecto.Migration

  def change do
    create table("other_reports", primary_key: false) do
      add :report_id, references(:base_reports), null: false
    end

    execute "ALTER TABLE other_reports ADD PRIMARY KEY (report_id);"
    create unique_index(:other_reports, [:report_id])
  end
end
