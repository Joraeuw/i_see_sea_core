defmodule ISeeSea.Constants.ReportType do
  @moduledoc """
  Constants representing each available report type.
  """

  @jellyfish "jellyfish"
  @meteorological "meteorological"
  @atypical "atypical"
  @pollution "pollution"

  @values [@jellyfish, @meteorological, @atypical, @pollution]

  def values do
    @values
  end

  Enum.each(@values, fn value ->
    def unquote(:"#{value}")(), do: unquote(value)
  end)
end
