defmodule ISeeSeaWeb.Utils.UserUtils do
  @moduledoc false
  alias ISeeSea.DB.Models.User

  def is_user_logged(%User{}), do: true
  def is_user_logged(_), do: false

  def is_user_verified(%User{verified: true}), do: true
  def is_user_verified(_), do: false
end
