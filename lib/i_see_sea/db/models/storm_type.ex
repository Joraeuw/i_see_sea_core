defmodule ISeeSea.DB.Models.StormType do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  @derive {ISeeSeaWeb.Focus, attrs: [:name]}

  @attrs [:name]

  @primary_key {:name, :string, []}
  schema "storm_types" do
    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
