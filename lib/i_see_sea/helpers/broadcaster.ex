defmodule ISeeSea.Helpers.Broadcaster do
  @moduledoc """
  Handles Broadcasting and events
  """
  alias ISeeSeaWeb.Endpoint
  alias ISeeSeaWeb.Focus
  alias ISeeSeaWeb.Lens

  def broadcast!(topic, event, payload, opts \\ []) do
    view = Keyword.get(opts, :view, :expanded)
    translate = Keyword.get(opts, :translate, false)

    processed_payload = Focus.view(payload, %Lens{view: view, translate: translate})
    Endpoint.broadcast!(topic, event, processed_payload)
  end
end
