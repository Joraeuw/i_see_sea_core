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

  def build(:base_report) do
    %Models.BaseReport{
      name: Faker.Lorem.sentence(),
      report_type: "none",
      report_date: Faker.DateTime.backward(5) |> DateTime.truncate(:second),
      longitude: Faker.Address.longitude(),
      latitude: Faker.Address.latitude(),
      comment: Faker.Lorem.paragraph(1..2)
    }
  end

  def build(:jellyfish_report) do
    %Models.JellyfishReport{
      quantity: 10,
      species: "unknown"
    }
  end

  def build(:pollution_report) do
    %Models.PollutionReport{}
  end

  def build(:pollution_type) do
    %Models.PollutionType{
      name: "oil"
    }
  end

  def build(:pollution_report_pollution_type) do
    %Models.PollutionReportPollutionType{}
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
