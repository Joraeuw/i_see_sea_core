defmodule ISeeSea.Constants.PictureTypes do
  @moduledoc false

  @jpg "image/jpeg"
  @png "image/png"
  @webp "image/webp"

  @jpg_suffix ".jpg"
  @png_suffix ".png"
  @webp_suffix ".webp"

  @content_type [@jpg, @png, @webp]
  @suffix [@jpg_suffix, @png_suffix, @webp_suffix]

  def content_types do
    @content_type
  end

  def suffixes do
    @suffix
  end

  def get_suffix(@jpg), do: {:ok, @jpg_suffix}
  def get_suffix(@png), do: {:ok, @png_suffix}
  def get_suffix(@webp), do: {:ok, @webp_suffix}
  def get_suffix(_), do: {:error, :invalid_content_type}

  defmacro jpg, do: unquote(@jpg)
  defmacro png, do: unquote(@png)
  defmacro webp, do: unquote(@webp)

  defmacro jpg_suffix, do: unquote(@jpg_suffix)
  defmacro png_suffix, do: unquote(@png_suffix)
  defmacro webp_suffix, do: unquote(@webp_suffix)
end
