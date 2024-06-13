defmodule ISeeSea.Repo.Migrations.PopulateConstants do
  use Ecto.Migration

  alias ISeeSea.DB.Models.WindType
  alias ISeeSea.DB.Models.SeaSwellType
  alias ISeeSea.DB.Models.FogType
  alias ISeeSea.Constants

  def change do
    for type <- Constants.FogType.values() do
      {:ok, _} = FogType.create(%{name: type})
    end

    for type <- Constants.SeaSwellType.values() do
      {:ok, _} = SeaSwellType.create(%{name: type})
    end

    for type <- Constants.WindType.values() do
      {:ok, _} = WindType.create(%{name: type})
    end
  end
end
