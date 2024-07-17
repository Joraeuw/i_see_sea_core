defmodule ISeeSea.Repo.Migrations.CreatePictureTable do
  use Ecto.Migration

  def change do
    create table("pictures") do
      add :file_size, :bigint, null: false
      add :content_type, :string, null: false
      add :image_data, :binary, null: false

      add :width, :integer, null: false
      add :height, :integer, null: false

      add :report_id, references(:base_reports, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
