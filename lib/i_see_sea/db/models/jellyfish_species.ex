defmodule ISeeSea.DB.Models.JellyfishSpecies do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  @derive {ISeeSeaWeb.Focus, attrs: [:name]}

  @attrs [:name]

  @primary_key {:name, :string, []}
  schema "jellyfish_species" do
    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  def values do
    __MODULE__.all()
    |> Enum.map(fn %__MODULE__{name: name} -> name end)
  end
end
