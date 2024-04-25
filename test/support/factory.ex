defmodule ISeeSea.Factory do
  @moduledoc """
  Data and Entity generator.
  """

  alias ISeeSea.Repo
  alias ISeeSea.DB.Models

  def build(:user) do
    %Models.User{
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      email: Faker.Internet.email(),
      username: Faker.Internet.user_name(),
      password: Bcrypt.hash_pwd_salt("A123456")
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
