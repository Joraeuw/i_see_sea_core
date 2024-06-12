defmodule ISeeSea.Repo.Migrations.CreateUniquePollutionTypeConstraint do
  use Ecto.Migration

  def change do
    execute("""
    DELETE FROM pollution_reports_pollution_types
    WHERE id NOT IN (
      SELECT MIN(id)
      FROM pollution_reports_pollution_types
      GROUP BY pollution_report_id, pollution_type_id
    )
    """)

    create unique_index(:pollution_reports_pollution_types, [:pollution_report_id, :pollution_type_id])
  end
end
