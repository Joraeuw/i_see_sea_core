defmodule ISeeSea.DB.Models.JellyfishReport do
  @moduledoc false

  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.DB.Models.JellyfishSpecies
  alias ISeeSea.DB.Models.BaseReport

  use ISeeSea.DB.DefaultModel, default_preloads: [:species, base_report: [:pictures, :user]]

  @required_attrs [:report_id, :quantity, :species_id]
  @allowed_attrs @required_attrs

  @primary_key false
  schema "jellyfish_reports" do
    field(:quantity, :string)

    belongs_to(:species, JellyfishSpecies, references: :name, type: :string)

    belongs_to(:base_report, BaseReport, primary_key: :report_id, foreign_key: :report_id)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:species, name: :jellyfish_reports_species_id_fkey)
    |> validate_inclusion(:quantity, JellyfishQuantityRange.values())
  end

  defimpl ISeeSeaWeb.Focus, for: __MODULE__ do
    require ISeeSeaWeb.Lens
    alias ISeeSeaWeb.Lens

    def view(
          %{base_report: base, species_id: species} = jellyfish_report,
          %Lens{view: Lens.expanded()} = lens
        ) do
      jellyfish_report
      |> Map.from_struct()
      |> Map.take([:quantity, :report_id])
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
      |> Map.merge(%{species: species})
    end

    def view(%{species_id: species} = jellyfish_report, %Lens{view: Lens.from_base()}) do
      jellyfish_report
      |> Map.from_struct()
      |> Map.take([:quantity, :report_id])
      |> Map.merge(%{species: species})
    end
  end
end
