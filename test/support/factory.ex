defmodule ISeeSea.Factory do
  @moduledoc """
  Data and Entity generator.
  """

  require ISeeSea.Constants.PictureTypes

  alias ISeeSea.Constants.PictureTypes
  alias ISeeSea.DB.Models.Role
  alias ISeeSea.Constants.ReportType
  alias ISeeSea.Repo
  alias ISeeSea.DB.Models

  def build(:user) do
    {:ok, %{id: end_user_id}} = Role.get(:end_user)

    %Models.User{
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      email: Faker.Internet.email(),
      username: Faker.Internet.user_name(),
      password: Bcrypt.hash_pwd_salt("A123456"),
      role_id: end_user_id
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
    base = build(:base_report, report_type: ReportType.jellyfish())

    %Models.JellyfishReport{
      quantity: 10,
      species: "unknown",
      base_report: base
    }
  end

  def build(:picture) do
    base = build(:base_report, report_type: ReportType.jellyfish())

    {:ok, img} = Image.open("./priv/example_images/sea_1.jpg")
    {width, height, _} = Image.shape(img)

    {:ok, img_binary} =
      Image.write(img, :memory, suffix: PictureTypes.jpg_suffix(), minimize_file_size: true)

    %Models.Picture{
      base_report: base,
      file_size: byte_size(img_binary),
      content_type: PictureTypes.jpg(),
      image_data: img_binary,
      width: width,
      height: height
    }
  end

  def build(:pollution_report) do
    base = build(:base_report, report_type: ReportType.pollution())

    %Models.PollutionReport{
      base_report: base
    }
  end

  def build(:atypical_activity_report) do
    base = build(:base_report, report_type: ReportType.atypical_activity())

    %Models.AtypicalActivityReport{
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
      base_report: build(:base_report, report_type: ReportType.meteorological()),
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
