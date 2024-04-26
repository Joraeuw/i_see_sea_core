defmodule ISeeSea.DB.Models.User do
  @moduledoc false

  alias ISeeSea.DB.Models.BaseReport
  use ISeeSea.DB.DefaultModel

  @derive {ISeeSeaWeb.Focus, attrs: [:first_name, :last_name, :email, :username, :phone_number]}

  @required_attrs [:first_name, :last_name, :email, :password, :username]
  @allowed_attrs [:phone_number | @required_attrs]

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string)
    field(:username, :string)
    field(:verified, :boolean, default: false)
    field(:phone_number, :string)

    has_many(:reports, BaseReport)

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :password, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
