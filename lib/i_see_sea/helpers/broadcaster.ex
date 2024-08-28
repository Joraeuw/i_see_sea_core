defmodule ISeeSea.Helpers.Broadcaster do
  @moduledoc """
  Handles Broadcasting and events
  """
  alias ISeeSeaWeb.Endpoint
  alias ISeeSeaWeb.Focus
  alias ISeeSeaWeb.Lens

  def broadcast!(topic, event, payload, view \\ :expanded) do
    processed_payload = Focus.view(payload, %Lens{view: view})
    Endpoint.broadcast!(topic, event, processed_payload)
  end
end
