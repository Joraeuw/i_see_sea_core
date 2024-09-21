defmodule ISeeSeaWeb.ReportsLive do
  use ISeeSeaWeb, :live_view

  def mount(_params, _session, socket) do
    current_filters = %{
      start_date: %{
        "field" => "inserted_at",
        "op" => ">=",
        "value" => Timex.shift(DateTime.utc_now(), days: -1)
      },
      end_date: %{"field" => "inserted_at", "op" => "<=", "value" => DateTime.utc_now()}
    }

    reports_pagination = %{page_size: 100, page: 1}

    new_socket =
      assign(socket,
        current_filters: to_form(current_filters),
        reports_pagination: reports_pagination,
        sidebar_open: true,
        current_page: 1,
        total_pages: 50,
        filter_menu_is_open: false
      )

    {:ok, new_socket}
  end
end
