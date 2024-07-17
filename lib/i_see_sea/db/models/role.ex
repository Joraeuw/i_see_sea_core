defmodule ISeeSea.DB.Models.Role do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  alias ISeeSea.DB.Models.Permission
  alias ISeeSea.DB.Models.PermissionRoles

  @roles [:admin, :end_user]

  schema "roles" do
    field(:name, :string)
    many_to_many(:permissions, Permission, join_through: PermissionRoles)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def get(role) when role in @roles do
    get_by(%{name: Atom.to_string(role)})
  end
end
