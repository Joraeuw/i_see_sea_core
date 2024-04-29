defmodule ISeeSea.Constants.SeaSwellType do
  @moduledoc false

  @strong "strong"
  @moderate "moderate"
  @weak "weak"
  @no_waves "no_waves"

  @values [@strong, @moderate, @weak, @no_waves]

  def values do
    @values
  end

  Enum.each(@values, fn value ->
    def unquote(:"#{value}")(), do: unquote(value)
  end)
end
