defmodule ISeeSea.DB.Models.PermissionRoles do
  @moduledoc false

  use ISeeSea.DB.DefaultModel

  alias ISeeSea.DB.Models.Role
  alias ISeeSea.DB.Models.Permission

  schema "permission_roles" do
    belongs_to(:permission, Permission)
    belongs_to(:role, Role)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:permission_id, :role_id])
    |> validate_required([:permission_id, :role_id])
  end
end
