defmodule ISeeSeaWeb.ConstantsController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSea.DB.Models.JellyfishSpecies
  alias ISeeSea.DB.Models.PollutionType

  alias ISeeSea.Constants

  # Static Types
  def picture_type(conn, _params) do
    success(conn, %{
      content_types: Constants.PictureTypes.content_types(),
      suffixes: Constants.PictureTypes.suffixes()
    })
  end

  def jellyfish_quantity(conn, _params) do
    success(conn, %{values: Constants.JellyfishQuantityRange.values()})
  end

  def report_type(conn, _params) do
    success(conn, %{values: Constants.ReportType.values()})
  end

  def fog_type(conn, _params) do
    success(conn, %{values: Constants.FogType.values()})
  end

  def sea_swell_type(conn, _params) do
    success(conn, %{values: Constants.SeaSwellType.values()})
  end

  def wind_type(conn, _params) do
    success(conn, %{values: Constants.WindType.values()})
  end

  def storm_type(conn, _params) do
    success(conn, %{values: Constants.StormType.values()})
  end

  # Dynamic Types
  def jellyfish_species(conn, _params) do
    success(conn, %{values: JellyfishSpecies.values()})
  end

  def pollution_type(conn, _params) do
    success(conn, %{values: PollutionType.values()})
  end
end
