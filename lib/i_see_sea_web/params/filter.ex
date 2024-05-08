defmodule ISeeSeaWeb.Params.Filter do
  @moduledoc false

  use ISeeSeaWeb, :param

  defparams :filter do
    optional(:filters, :string)
    optional(:order_by, {:array, :string})
    optional(:order_direction, {:array, :string})
  end

  defparams :pagination do
    optional(:page, :integer)
    optional(:page_sze, :integer)
  end
end
