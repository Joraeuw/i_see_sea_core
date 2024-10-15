defmodule ISeeSeaWeb.ErrorHTMLTest do
  use ISeeSeaWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template
  import ISeeSeaWeb.Trans

  test "renders 404.html" do
    assert render_to_string(ISeeSeaWeb.ErrorHTML, "404", "html", []) == translate(@locale, "test_errors.not_found")
  end

  test "renders 500.html" do
    assert render_to_string(ISeeSeaWeb.ErrorHTML, "500", "html", []) == translate(@locale, "test_errors.internal_server_error")
  end
end
