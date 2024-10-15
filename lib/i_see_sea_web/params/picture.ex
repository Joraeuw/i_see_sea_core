defmodule ISeeSeaWeb.Params.Picture do
  @moduledoc false
  use ISeeSeaWeb, :param

  defparams :show do
    required(:picture_id, :integer)
  end
end
