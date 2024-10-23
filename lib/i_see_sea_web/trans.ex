defmodule ISeeSeaWeb.Trans do
  @moduledoc """
  Translates text based on the locale from the session.
  """
  @default_locale "bg"
  use Linguist.Vocabulary

  locale("en", Path.join([__DIR__, "/trans/en.exs"]))
  locale("bg", Path.join([__DIR__, "/trans/bg.exs"]))

  def translate(locale, path) when is_bitstring(path) do
    t(locale, path)
    |> case do
      {:error, :no_translation} -> path
      {:ok, string} -> string
    end
  end

  def maybe_translate_entity(entity, translate?, path, opts \\ [])

  def maybe_translate_entity(entity, false, _path, _opts), do: entity

  def maybe_translate_entity(entity, true, path, opts) do
    ignore = Keyword.get(opts, :ignore, [])

    entity
    |> Enum.map(fn {key, value} ->
      if key in ignore do
        {key, value}
      else
        {key, maybe_translate_value(value, "#{path}.#{key}")}
      end
    end)
    |> Enum.into(%{})
  end

  defp maybe_translate_value(value, path) when is_binary(value) do
    translate(@default_locale, "#{path}.#{value}")
  end

  defp maybe_translate_value(value, path) when is_list(value) do
    Enum.map(value, &maybe_translate_value(&1, "#{path}.#{&1}"))
  end

  defp maybe_translate_value(value, _path), do: value
end
