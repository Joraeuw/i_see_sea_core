defmodule ISeeSea.DB.Models.BaseReport do
  @moduledoc false

  alias ISeeSea.Constants.ReportType
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.User

  use ISeeSea.DB.DefaultModel

  @derive {ISeeSeaWeb.Focus,
           attrs: [:name, :report_type, :report_date, :longitude, :latitude, :comment]}

  @required_attrs [:user_id, :name, :report_type, :report_date, :longitude, :latitude]
  @allowed_attrs [:comment | @required_attrs]

  schema "base_reports" do
    field(:name, :string)
    field(:report_type, :string)
    field(:report_date, :utc_datetime)
    field(:longitude, :float)
    field(:latitude, :float)
    field(:comment, :string)

    belongs_to(:user, User)

    has_one(:jellyfish_report, JellyfishReport, foreign_key: :report_id)
    has_one(:pollution_report, PollutionReport, foreign_key: :report_id)

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:report_type, ReportType.values())
  end
end
