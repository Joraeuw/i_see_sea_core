defmodule ISeeSea.Constants.ReportType do
  @moduledoc """
  Constants representing each available report type.
  """

  @jellyfish "jellyfish"
  @meteorological "meteorological"
  @atypical_activity "atypical_activity"
  @pollution "pollution"
  @other "other"
  @all "all"

  @values [@jellyfish, @meteorological, @atypical_activity, @pollution, @other]

  def values do
    @values
  end

  def filter_values do
    [@all | @values]
  end

  Enum.each(@values, fn value ->
    defmacro unquote(:"#{value}")(), do: unquote(value)
  end)
end
