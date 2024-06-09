defmodule ISeeSeaWeb.Params.Picture do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use ISeeSeaWeb, :param

      defparams :show do
        required(:picture_id, :integer)
      end
    end
  end
end
