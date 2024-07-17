defmodule ISeeSea.Repo.Migrations.PopulatePollutionTypes do
  alias ISeeSea.DB.Models.PollutionType
  use Ecto.Migration

  def change do
    PollutionType.create(%{name: "oil"})
    PollutionType.create(%{name: "plastic"})
    PollutionType.create(%{name: "biological"})
  end
end
