defmodule KlepsidraWeb.PageControllerTest do
  use KlepsidraWeb.ConnCase

  # This test simply reads the template controller, and will be replaced
  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
