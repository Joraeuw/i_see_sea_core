defmodule ISeeSeaWeb.Trans do
  @moduledoc """
  Translates the text based on locale from session
  """

  use Linguist.Vocabulary

  locale "en", Path.join([__DIR__, "/trans/en.exs"])
  locale "bg", Path.join([__DIR__, "/trans/bg.exs"])
end
