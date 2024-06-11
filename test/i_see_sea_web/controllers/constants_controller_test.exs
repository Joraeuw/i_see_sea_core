defmodule ISeeSeaWeb.ConstantsControllerTest do
  @moduledoc false

  use ISeeSeaWeb.ConnCase, async: true

  describe "picture_type/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :picture_type))
        |> json_response(200)

      assert response == %{
               "content_types" => ["image/jpeg", "image/png", "image/webp"],
               "suffixes" => [".jpg", ".png", ".webp"]
             }
    end
  end

  describe "jellyfish_quantity/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :jellyfish_quantity))
        |> json_response(200)

      assert response == %{
               "values" => ["1", "2 to 5", "6 to 10", "11 to 99", "100+"]
             }
    end
  end

  describe "report_type/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :report_type))
        |> json_response(200)

      assert response == %{
               "values" => ["jellyfish", "meteorological", "atypical_activity", "pollution"]
             }
    end
  end

  describe "fog_type/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :fog_type))
        |> json_response(200)

      assert response == %{
               "values" => ["very_thick", "thick", "moderate", "light", "no_fog"]
             }
    end
  end

  describe "sea_swell_type/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :sea_swell_type))
        |> json_response(200)

      assert response == %{
               "values" => ["strong", "moderate", "weak", "no_waves"]
             }
    end
  end

  describe "wind_type/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :wind_type))
        |> json_response(200)

      assert response == %{"values" => ["hurricane", "strong", "moderate", "weak", "no_wind"]}
    end
  end

  describe "jellyfish_species/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :jellyfish_species))
        |> json_response(200)

      assert response == %{
               "values" => [
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
             }
    end
  end

  describe "pollution_type/2" do
    test "successfully retrieve constants", %{conn: conn} do
      response =
        conn
        |> get(Routes.constants_path(conn, :pollution_type))
        |> json_response(200)

      assert response == %{
               "values" => []
             }
    end
  end
end
