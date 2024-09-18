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
  alias ISeeSea.Constants
  alias ISeeSea.DB.Models.Role
  alias ISeeSea.Repo
  alias ISeeSea.Factory

  require Constants.SeaSwellType



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

      pollution_type = Factory.insert!(:pollution_type, name: "new")
      pollution_type = Factory.insert!(:pollution_type, name: "new_2")

      Factory.insert!(:pollution_report)
      pollution_report = Factory.insert!(:pollution_report)
      Factory.insert!(:picture, base_report: pollution_report.base_report)

      Factory.insert!(:pollution_report_pollution_type, %{
        pollution_report_id: pollution_report.report_id,
        pollution_type_id: pollution_type.name
      })

      Factory.insert!(:meteorological_report,
        wind_type_id: Constants.WindType.strong(),
        fog_type_id: Constants.FogType.thick(),
        sea_swell_type_id: Constants.SeaSwellType.no_waves()
      )

      Factory.insert!(:other_report)
      Factory.insert!(:other_report)
      Factory.insert!(:other_report)
    end)
  end
end

ISeeSea.Seeder.seed()
