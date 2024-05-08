defmodule ISeeSeaWeb.Lens do
  @moduledoc """
  Lens add additional security level to the app.
  No variable or entity shall be exposed unless it is specified.
  """
  defstruct user: nil, view: :expanded

  defmacro expanded do
    quote do
      :expanded
    end
  end

  defmacro simplified do
    quote do
      :simplified
    end
  end

  defmacro from_base do
    quote do
      :from_base
    end
  end
end
