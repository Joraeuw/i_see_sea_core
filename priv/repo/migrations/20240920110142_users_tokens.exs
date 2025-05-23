defmodule ISeeSea.Repo.Migrations.UsersTokens do
  alias ISeeSea.DB.Models.User
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :verified_at, :utc_datetime, null: true
    end

    flush()

    Enum.each(User.all!(), fn %User{id: user_id} ->
      User.update(user_id, %{verified_at: DateTime.utc_now()})
    end)

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
