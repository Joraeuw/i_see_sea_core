defmodule ISeeSea.Constants.WindType do
  @moduledoc false

  @values ["hurricane", "strong", "moderate", "weak", "no_wind"]

  def values do
    @values
  end

  Enum.each(@values, fn value ->
    def unquote(:"#{value}")(), do: unquote(value)
  end)
end
