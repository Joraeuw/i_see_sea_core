defmodule ISeeSea.Emails do
  @moduledoc """
  Manages emails
  """
  alias ISeeSea.Mailer
  alias ISeeSea.DB.Models.User
  alias ISeeSea.Helpers.Environment
  import Swoosh.Email

  def account_confirmation_email(%User{email: email}, confirmation_token) do
    new()
    |> to(email)
    |> from(Environment.i_see_sea_mail())
    |> subject("Email Confirmation")
    |> html_body(
      "<p>Please confirm your email by clicking the link: <a href=\"#{confirmation_url(confirmation_token)}\">Confirm Email</a></p>"
    )
    |> Mailer.deliver()
  end

  defp confirmation_url(token) do
    "#{Environment.backend_url()}/api/verify-email/#{token}"
  end
end
