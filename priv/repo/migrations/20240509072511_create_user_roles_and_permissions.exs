defmodule ISeeSea.Repo.Migrations.CreateUserRolesAndPermissions do
  use Ecto.Migration

  def change do
    create table("permissions") do
      add :name, :string, null: false
    end

    create table("roles") do
      add :name, :string, null: false
    end

    create table("permission_roles") do
      add :permission_id, references(:permissions), null: false
      add :role_id, references(:roles), null: false
    end

    alter table("users") do
      add :role_id, references(:roles), null: false
    end

    create unique_index(:permissions, [:name])
    create unique_index(:roles, [:name])
    create unique_index(:permission_roles, [:permission_id, :role_id])
  end
end
