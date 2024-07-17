defmodule ISeeSea.Constants.StormType do
  @moduledoc false

  @thunderstorm "thunderstorm"
  @rain "rain"
  @hailstorm "hailstorm"
  @no_storm "no_storm"

  @values [@thunderstorm, @rain, @hailstorm, @no_storm]

  def values do
    @values
  end

  Enum.each(@values, fn value ->
    def unquote(:"#{value}")(), do: unquote(value)
  end)
end
