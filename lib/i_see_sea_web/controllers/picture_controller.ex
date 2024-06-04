defmodule ISeeSeaWeb.PictureController do
  alias ISeeSea.DB.Models.Picture
  use ISeeSeaWeb, :controller

  def show(conn, params) do
    with {:ok, %{picture_id: picture_id}} <- validate(:show, params),
         {:ok, %Picture{image_data: data, content_type: type}} <- Picture.get(picture_id) do
      success_binary(conn, data, type)
    else
      error ->
        error(conn, error)
    end
  end
end
