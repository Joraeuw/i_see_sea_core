defmodule ISeeSea.Repo do
  use Ecto.Repo,
    otp_app: :i_see_sea,
    adapter: Ecto.Adapters.Postgres
end
