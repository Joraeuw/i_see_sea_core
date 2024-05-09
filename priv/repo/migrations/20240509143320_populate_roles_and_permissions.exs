defmodule ISeeSea.Repo.Migrations.PopulateRolesAndPermissions do
  @moduledoc false
  use Ecto.Migration

  alias ISeeSea.DB.Models.PermissionRoles
  alias ISeeSea.DB.Models.Permission
  alias ISeeSea.DB.Models.Role

  @roles ["end_user", "admin"]
  @permissions [
    "i_see_sea:sessions:refresh",
    "i_see_sea:users:list_reports",
    "i_see_sea:reports:create"
  ]

  def change do
    role_ids =
      for role <- @roles do
        %{name: role}
        |> Role.create()
        |> then(fn {:ok, %Role{id: id}} -> id end)
      end

    permission_ids =
      for permission <- @permissions do
        %{name: permission}
        |> Permission.create()
        |> then(fn {:ok, %Permission{id: id}} -> id end)
      end

    for role_id <- role_ids, permission_id <- permission_ids do
      PermissionRoles.create(%{role_id: role_id, permission_id: permission_id})
    end
  end
end
