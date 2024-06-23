defmodule ISeeSea.Flop do
  @moduledoc """
  Module that handles filters and pagination using Flop.
  """

  use Flop, repo: ISeeSea.Repo, default_limit: 10, max_limit: 9999
end
