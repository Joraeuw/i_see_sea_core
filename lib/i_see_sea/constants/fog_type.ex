defmodule ISeeSea.Constants.FogType do
  @moduledoc false

  @very_thick "very_thick"
  @thick "thick"
  @moderate "moderate"
  @light "light"
  @no_fog "no_fog"

  @values [@very_thick, @thick, @moderate, @light, @no_fog]

  def values do
    @values
  end

  Enum.each(@values, fn value ->
    def unquote(:"#{value}")(), do: unquote(value)
  end)
end
