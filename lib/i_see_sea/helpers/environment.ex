defmodule ISeeSea.Helpers.Environment do
  @moduledoc """
  Contains easy access to environment variables.
  """

  @not_found_val :not_found

  def backend_url do
    get(:backend_url, [:i_see_sea, :backend_url])
  end

  def i_see_sea_mail do
    get(:username, [:i_see_sea, ISeeSea.Mailer, :username])[:username]
  end

  defp get(name, level) do
    :persistent_term.get(name, @not_found_val)
    |> case do
      @not_found_val -> persist_env(name, level)
      val -> val
    end
  end

  defp persist_env(name, level) do
    val = Kernel.apply(Application, :get_env, level)
    :persistent_term.put(name, val)
    val
  end
end
