defmodule ISeeSeaWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](https://hexdocs.pm/gettext),
  your module gains a set of macros for translations, for example:

      import ISeeSeaWeb.Gettext

      # Simple translation
      t!("Here is the string to translate")

      # Plural translation
      nt!("Here is the string to translate",
               "Here are the strings to translate",
               3)

      # Domain-based translation
      dt!("errors", "Here is the error message to translate")

  See the [Gettext Docs](https://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext, otp_app: :i_see_sea
end
