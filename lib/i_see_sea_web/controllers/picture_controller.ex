defmodule ISeeSeaWeb.PictureController do
  use ISeeSeaWeb, :controller
  use ISeeSeaWeb.ApiSpec.Operations.Picture

  alias ISeeSea.DB.Models.Picture

  def show(conn, params) do
    with {:ok, %{picture_id: picture_id}} <- Params.Picture.validate(:show, params),
         {:ok, %Picture{image_data: data, content_type: type}} <- Picture.get(picture_id) do
      success_binary(conn, data, type)
    else
      error ->
        error(conn, error)
    end
  end
end
