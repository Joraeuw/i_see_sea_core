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
  alias ISeeSea.Repo
  alias ISeeSea.Factory

  def seed do
    Repo.transaction(fn ->
      Factory.insert!(:user)
      Factory.insert!(:user)

      Factory.insert!(:jellyfish_report)
      Factory.insert!(:jellyfish_report)
      Factory.insert!(:jellyfish_report)

      Factory.insert!(:pollution_type)
      pollution_type = Factory.insert!(:pollution_type, %{name: "plastic"})

      Factory.insert!(:pollution_report)
      pollution_report = Factory.insert!(:pollution_report)

      Factory.insert!(:pollution_report_pollution_type, %{
        pollution_report_id: pollution_report.report_id,
        pollution_type_id: pollution_type.name
      })
    end)
  end
end

ISeeSea.Seeder.seed()
