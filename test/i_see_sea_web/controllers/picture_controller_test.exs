defmodule ISeeSeaWeb.PictureControllerTest do
  @moduledoc false

  use ISeeSeaWeb.ConnCase, async: true
  require ISeeSea.Constants.PictureTypes

  alias ISeeSea.Constants.PictureTypes

  import ISeeSeaWeb.Trans

  setup do
    pollution_report = insert!(:pollution_report)
    picture = insert!(:picture, base_report: pollution_report.base_report)

    %{picture: picture}
  end

  describe "show/2" do
    test "successfully retrieve an image", %{conn: conn, picture: picture} do
      data =
        Image.open!("./priv/example_images/sea_1.jpg")
        |> Image.write!(:memory, suffix: PictureTypes.jpg_suffix(), minimize_file_size: true)

      response =
        conn
        |> get(Routes.picture_path(conn, :show, picture.id))
        |> response(200)

      assert response == data
    end

    test "return an error when image is not found", %{conn: conn} do
      response =
        conn
        |> get(Routes.picture_path(conn, :show, 0))
        |> json_response(404)

      assert response == %{
               "message" => translate(@locale, "test_errors.action_failed"),
               "reason" => translate(@locale, "test_errors.no_entity")
             }
    end
  end
end
