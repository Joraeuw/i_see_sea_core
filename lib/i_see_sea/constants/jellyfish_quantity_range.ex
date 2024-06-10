defmodule ISeeSea.Constants.JellyfishQuantityRange do
  @moduledoc false

  @values [
    "1",
    "2 to 5",
    "6 to 10",
    "11 to 99",
    "100+"
  ]

  def values, do: @values

  Enum.each(@values, fn value ->
    def unquote(:"#{"from_" <> String.replace(value, " ", "_")}")(), do: unquote(value)
  end)
end
