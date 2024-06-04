defmodule ISeeSea.DB.Models.PicturesReport do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Models.Picture

  schema "pictures_report" do
    belongs_to(:picture, Picture, foreign_key: :picture_id)
    belongs_to(:base_report, BaseReport, primary_key: :report_id, foreign_key: :report_id)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:picture_id, :report_id])
    |> validate_required([:picture_id, :report_id])
  end
end
