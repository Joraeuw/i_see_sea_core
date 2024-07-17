defmodule ISeeSeaWeb.Plug.EnsureAuthenticated do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :i_see_sea,
    module: ISeeSea.Authentication.Tokenizer,
    error_handler: ISeeSea.Authentication.ErrorHandler

  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer", claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
  plug(ISeeSeaWeb.Plug.AssignUser)
end
