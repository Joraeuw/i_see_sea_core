defmodule ISeeSea.Helpers.With do
  @moduledoc """
  Helpers for with statements.
  """

  def check(true, _), do: :ok
  def check(false, error), do: {:error, error}
end
