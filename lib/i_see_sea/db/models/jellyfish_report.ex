defmodule ISeeSea.DB.Models.JellyfishReport do
  @moduledoc false

  alias ISeeSea.DB.Models.BaseReport
  use ISeeSea.DB.DefaultModel, default_preloads: [:base_report]

  @required_attrs [:report_id, :quantity]
  @allowed_attrs [:species | @required_attrs]

  @primary_key false
  schema "jellyfish_reports" do
    field(:quantity, :integer)
    field(:species, :string, default: "")

    belongs_to(:base_report, BaseReport, primary_key: :report_id, foreign_key: :report_id)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
  end

  defimpl ISeeSeaWeb.Focus, for: __MODULE__ do
    require ISeeSeaWeb.Lens
    alias ISeeSeaWeb.Lens

    def view(%{base_report: base} = jellyfish_report, %Lens{view: Lens.expanded()} = lens) do
      jellyfish_report
      |> Map.from_struct()
      |> Map.take([:quantity, :species, :report_id])
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
    end
  end
end
