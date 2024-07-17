defmodule ISeeSea.DB.Models.Permission do
  @moduledoc false
  use ISeeSea.DB.DefaultModel

  schema "permissions" do
    field(:name, :string)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
