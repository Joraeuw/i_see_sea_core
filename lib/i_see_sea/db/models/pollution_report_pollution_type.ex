defmodule ISeeSea.DB.Models.PollutionReportPollutionType do
  @moduledoc false

  alias ISeeSea.DB.Models.PollutionType
  alias ISeeSea.DB.Models.PollutionReport

  use ISeeSea.DB.DefaultModel

  schema "pollution_reports_pollution_types" do
    belongs_to(:pollution_report, PollutionReport, references: :report_id)
    belongs_to(:pollution_type, PollutionType, references: :name, type: :string)
    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:pollution_report_id, :pollution_type_id])
    |> validate_required([:pollution_report_id, :pollution_type_id])
    |> unique_constraint(:pollution_type_id,
      name: :pollution_reports_pollution_types_pollution_report_id_pollution
    )
  end
end
