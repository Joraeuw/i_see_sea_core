defmodule ISeeSea.DB.Models.User do
  @moduledoc false

  use ISeeSea.DB.DefaultModel, default_preloads: [role: :permissions]

  alias ISeeSea.DB.Models.Role
  alias ISeeSea.DB.Models.BaseReport

  @derive {ISeeSeaWeb.Focus,
           attrs: [:first_name, :last_name, :email, :username, :phone_number, :verified]}

  @required_attrs [:first_name, :last_name, :email, :password, :username]
  @allowed_attrs [:phone_number, :role_id, :verified | @required_attrs]

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string)
    field(:username, :string)
    field(:verified, :boolean, default: false)
    field(:verified_at, :utc_datetime)
    field(:phone_number, :string)

    has_many(:reports, BaseReport)
    belongs_to(:role, Role)

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    {:ok, %{id: end_user_id}} = Role.get(:end_user)

    attrs =
      if struct.id do
        attrs
      else
        Map.put_new(attrs, :role_id, end_user_id)
      end

    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> put_password_hash()
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  def valid_password?(%__MODULE__{password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :password, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  def is_admin?(%__MODULE__{id: user_id, role_id: user_role_id}) do
    {:ok, admin} = Role.get_by(%{name: "admin"})

    IO.inspect(user_id)
    user_role_id === admin.id
  end

  def is_admin?(nil), do: false
end
