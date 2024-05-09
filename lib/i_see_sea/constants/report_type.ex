defmodule ISeeSea.Constants.ReportType do
  @moduledoc """
  Constants representing each available report type.
  """

  @jellyfish "jellyfish"
  @meteorological "meteorological"
  @atypical_activity "atypical_activity"
  @pollution "pollution"

  @values [@jellyfish, @meteorological, @atypical_activity, @pollution]

  def values do
    @values
  end

  Enum.each(@values, fn value ->
    def unquote(:"#{value}")(), do: unquote(value)
  end)
end
