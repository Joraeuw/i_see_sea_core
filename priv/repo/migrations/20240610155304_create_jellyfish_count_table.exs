defmodule ISeeSea.Repo.Migrations.CreateJellyfishCountTable do
  use Ecto.Migration

  alias ISeeSea.DB.Models.JellyfishSpecies

  @species [
    "dont_know",
    "aurelia_aurita",
    "cotylorhiza_tuberculata",
    "pelagia_noctiluca",
    "beroe_ovata",
    "salp",
    "cassiopea_andromeda",
    "cotyllorhiza_erythrea",
    "marivagia_stellata",
    "cestus_veneris",
    "porpita_porpita",
    "chrysaora_pseudoocellata",
    "aquorea_forskalea",
    "hydromedusae",
    "other"
  ]

  def change do
    create table("jellyfish_species", primary_key: false) do
      add :name, :string, null: false, primary_key: true
      timestamps()
    end

    alter table("jellyfish_reports") do
      remove :species
      add :species_id, references(:jellyfish_species, column: :name, type: :string), null: false
    end

    flush()

    Enum.each(@species, fn species_name ->
      {:ok, _} = JellyfishSpecies.create(%{name: species_name})
    end)
  end
end
