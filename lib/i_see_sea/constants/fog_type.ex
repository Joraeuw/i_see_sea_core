defmodule ISeeSea.Constants.FogType do
  @moduledoc false

  @values ["very_thick", "thick", "moderate", "light", "no_fog"]

  def values do
    @values
  end

  Enum.each(@values, fn value ->
    def unquote(:"#{value}")(), do: unquote(value)
  end)
end
