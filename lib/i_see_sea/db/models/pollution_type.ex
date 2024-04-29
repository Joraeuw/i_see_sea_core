defmodule ISeeSea.DB.Models.PollutionType do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  @derive {ISeeSeaWeb.Focus, attrs: [:name]}

  @attrs [:name]

  @primary_key {:name, :string, []}
  schema "pollution_types" do
    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
