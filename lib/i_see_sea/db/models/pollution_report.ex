defmodule ISeeSea.DB.Models.PollutionReport do
  @moduledoc false

  use ISeeSea.DB.DefaultModel,
    default_preloads: [:pollution_types, base_report: [:pictures, :user]]

  alias ISeeSea.DB.Models.PollutionReportPollutionType
  alias ISeeSea.DB.Models.PollutionType
  alias ISeeSea.DB.Models.BaseReport

  @attrs [:report_id]

  @primary_key false
  schema "pollution_reports" do
    belongs_to(:base_report, BaseReport, primary_key: :report_id, foreign_key: :report_id)

    many_to_many(:pollution_types, PollutionType,
      join_through: PollutionReportPollutionType,
      join_keys: [pollution_report_id: :report_id, pollution_type_id: :name]
    )
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  defimpl ISeeSeaWeb.Focus, for: __MODULE__ do
    require ISeeSeaWeb.Lens
    alias ISeeSeaWeb.Lens

    def view(
          pollution_report,
          %Lens{view: Lens.expanded(), translate: translate} = lens
        ) do
      %{base_report: base, pollution_types: pollution_types} =
        Repo.preload(pollution_report, :pollution_types)

      pollution_report
      |> Map.from_struct()
      |> Map.take([:report_id])
      |> ISeeSeaWeb.Trans.maybe_translate_entity(translate, "pollution_report")
      |> Map.merge(%{
        pollution_types:
          pollution_types
          |> ISeeSeaWeb.Focus.view(lens)
          |> Enum.map(fn %{name: name} -> name end)
      })
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
    end

    def view(
          pollution_report,
          %Lens{view: Lens.from_base(), translate: translate} = lens
        ) do
      %{pollution_types: pollution_types} =
        Repo.preload(pollution_report, :pollution_types)

      pollution_report
      |> Map.from_struct()
      |> Map.take([:report_id])
      |> ISeeSeaWeb.Trans.maybe_translate_entity(translate, "pollution_report")
      |> Map.merge(%{
        pollution_types:
          pollution_types
          |> ISeeSeaWeb.Focus.view(lens)
          |> override_nil()
          |> Enum.map(fn %{name: name} -> name end)
      })
    end

    defp override_nil(nil), do: []
    defp override_nil(entities), do: entities
  end
end
