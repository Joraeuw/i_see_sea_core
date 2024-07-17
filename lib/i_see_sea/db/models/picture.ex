defmodule ISeeSea.DB.Models.Picture do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  alias ISeeSea.Constants.PictureTypes
  alias ISeeSea.Helpers.Environment
  alias ISeeSea.DB.Models.BaseReport

  @required_attrs [:report_id, :file_size, :content_type, :image_data, :width, :height]
  @allowed_attrs @required_attrs

  schema "pictures" do
    field(:file_size, :integer)
    field(:content_type, :string)
    field(:image_data, :binary)
    field(:width, :integer)
    field(:height, :integer)

    belongs_to(:base_report, BaseReport, foreign_key: :report_id)

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:content_type, PictureTypes.content_types())
  end

  def get_uri!(%__MODULE__{id: id}) do
    Environment.backend_url() <> "/api/pictures/" <> Integer.to_string(id)
  end
end
