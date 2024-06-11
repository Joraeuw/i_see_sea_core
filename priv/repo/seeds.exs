# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ISeeSea.Repo.insert!(%ISeeSea.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Code.require_file("./test/support/factory.ex")

defmodule ISeeSea.Seeder do
  alias ISeeSea.DB.Models.Role
  alias ISeeSea.Repo
  alias ISeeSea.Factory

  def seed do
    Repo.transaction(fn ->
      {:ok, %{id: admin_id}} = Role.get(:admin)

      Factory.insert!(:user,
        email: "i_see_sea@gmail.com",
        username: "i_sea_sea",
        role_id: admin_id
      )

      j_r = Factory.insert!(:jellyfish_report)
      Factory.insert!(:jellyfish_report)
      Factory.insert!(:jellyfish_report)

      Factory.insert!(:picture, base_report: j_r.base_report)

      Factory.insert!(:pollution_type)
      pollution_type = Factory.insert!(:pollution_type, name: "plastic")
      pollution_type = Factory.insert!(:pollution_type, name: "biological")

      Factory.insert!(:pollution_report)
      pollution_report = Factory.insert!(:pollution_report)
      Factory.insert!(:picture, base_report: pollution_report.base_report)

      Factory.insert!(:pollution_report_pollution_type, %{
        pollution_report_id: pollution_report.report_id,
        pollution_type_id: pollution_type.name
      })

      Factory.insert!(:wind_type, name: "hurricane")
      strong_wind = Factory.insert!(:wind_type, name: "strong")
      Factory.insert!(:wind_type, name: "moderate")
      Factory.insert!(:wind_type, name: "weak")
      Factory.insert!(:wind_type)

      thick_fog = Factory.insert!(:fog_type, name: "very_thick")
      Factory.insert!(:fog_type, name: "thick")
      Factory.insert!(:fog_type, name: "moderate")
      Factory.insert!(:fog_type, name: "light")
      Factory.insert!(:fog_type)

      Factory.insert!(:sea_swell_type, name: "strong")
      Factory.insert!(:sea_swell_type, name: "moderate")
      Factory.insert!(:sea_swell_type, name: "weak")
      no_wave = Factory.insert!(:sea_swell_type)

      Factory.insert!(:meteorological_report,
        wind_type: strong_wind,
        fog_type: thick_fog,
        sea_swell_type: no_wave
      )
    end)
  end
end

ISeeSea.Seeder.seed()
