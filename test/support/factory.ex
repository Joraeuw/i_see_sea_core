defmodule ISeeSea.Factory do
  @moduledoc """
  Data and Entity generator.
  """

  alias ISeeSea.Constants
  require ISeeSea.Constants.JellyfishQuantityRange, as: JellyfishQuantityRange
  require ISeeSea.Constants.PictureTypes, as: PictureTypes
  require ISeeSea.Constants.ReportType, as: ReportType
  require ISeeSea.Constants.StormType, as: StormType

  alias ISeeSea.Repo

  alias ISeeSea.DB.Models
  alias ISeeSea.DB.Models.Role

  def build(:user) do
    {:ok, %{id: end_user_id}} = Role.get(:end_user)

    %Models.User{
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      email: Faker.Internet.email(),
      username: Faker.Internet.user_name(),
      password: Bcrypt.hash_pwd_salt("A123456"),
      role_id: end_user_id,
      verified: true
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
      quantity: JellyfishQuantityRange.from_2_to_5(),
      species_id: "other",
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
      base_report: base,
      storm_type_id: StormType.hailstorm()
    }
  end

  def build(:other_report) do
    base = build(:base_report, report_type: ReportType.other())

    %Models.OtherReport{
      base_report: base
    }
  end

  def build(:user_token) do
    %Models.UserToken{
      token: "token",
      user: build(:user),
      context: "session"
    }
  end

  def build(:pollution_type) do
    %Models.PollutionType{name: "oil"}
  end

  def build(:pollution_report_pollution_type) do
    %Models.PollutionReportPollutionType{}
  end

  def build(:meteorological_report) do
    %Models.MeteorologicalReport{
      base_report: build(:base_report, report_type: ReportType.meteorological()),
      fog_type_id: Constants.FogType.light(),
      wind_type_id: Constants.WindType.hurricane(),
      sea_swell_type_id: Constants.SeaSwellType.no_waves()
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
