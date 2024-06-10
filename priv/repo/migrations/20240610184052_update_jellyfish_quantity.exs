defmodule ISeeSea.Repo.Migrations.UpdateJellyfishQuantity do
  use Ecto.Migration

  def change do
    alter table("jellyfish_reports") do
      remove :quantity
      add :quantity, :string, null: false
    end
  end
end
