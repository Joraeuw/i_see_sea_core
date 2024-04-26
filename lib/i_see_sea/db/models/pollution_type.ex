defmodule ISeeSea.DB.Models.PollutionType do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  @derive {ISeeSeaWeb.Focus, attrs: [:name]}

  @attrs [:name]

  schema "pollution_types" do
    field :name, :string

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  def create(name) when is_bitstring(name) do
    %__MODULE__{name: name}

    case get_by(%{name: name}) do
      {:error, :not_found, _} ->
        create(%{name: name}, [])

      {:ok, entity} ->
        {:ok, entity}
    end
  end
end
