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
    user = build(:user)

    %Models.BaseReport{
      name: Faker.Lorem.sentence(),
      report_type: "none",
      user: user,
      report_date: Faker.DateTime.backward(5) |> DateTime.truncate(:second),
      longitude: Faker.Address.longitude(),
      latitude: Faker.Address.latitude(),
      comment: Faker.Lorem.paragraph()
    }
  end

  def build(:jellyfish_report) do
    base = build(:base_report)

    %Models.JellyfishReport{
      quantity: 10,
      species: "unknown",
      base_report: base
    }
  end

  def build(:pollution_report) do
    base = build(:base_report)

    %Models.PollutionReport{
      base_report: base
    }
  end

  def build(:pollution_type) do
    %Models.PollutionType{name: "oil"}
  end

  def build(:pollution_report_pollution_type) do
    %Models.PollutionReportPollutionType{}
  end

  def build(:wind_type) do
    %Models.WindType{
      name: "no_wind"
    }
  end

  def build(:fog_type) do
    %Models.FogType{
      name: "no_fog"
    }
  end

  def build(:sea_swell_type) do
    %Models.SeaSwellType{
      name: "no_waves"
    }
  end

  def build(:meteorological_report) do
    %Models.MeteorologicalReport{
      base_report: build(:base_report),
      fog_type: build(:fog_type),
      wind_type: build(:wind_type),
      sea_swell_type: build(:sea_swell_type)
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
