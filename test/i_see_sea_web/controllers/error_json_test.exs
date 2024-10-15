defmodule ISeeSeaWeb.ErrorJSONTest do
  use ISeeSeaWeb.ConnCase, async: true

  import ISeeSeaWeb.Trans

  test "renders 404" do
    assert ISeeSeaWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: translate(@locale, "test_errors.not_found")}}
  end

  test "renders 500" do
    assert ISeeSeaWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: translate(@locale, "test_errors.internal_server_error")}}
  end
end
