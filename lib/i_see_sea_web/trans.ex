defmodule ISeeSeaWeb.Trans do
  @moduledoc """
  Translates the text based on locale from session
  """
  @default_locale "bg"
  use Linguist.Vocabulary

  locale("en", Path.join([__DIR__, "/trans/en.exs"]))
  locale("bg", Path.join([__DIR__, "/trans/bg.exs"]))

  def translate(locale, path) do
    t(locale, path)
    |> case do
      {:error, :no_translation} ->
        path

      {:ok, string} ->
        string
    end
  end
end
