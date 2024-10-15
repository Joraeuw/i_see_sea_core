defmodule ISeeSeaWeb.PageControllerTest do
  use ISeeSeaWeb.ConnCase

  import ISeeSeaWeb.Trans

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ translate(@locale, "test_errors.peace_of_mind")
  end
end
