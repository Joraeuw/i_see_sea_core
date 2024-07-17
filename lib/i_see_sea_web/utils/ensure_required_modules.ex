defmodule ISeeSeaWeb.Utils.EnsureRequiredModules do
  @moduledoc """
  Ensures that no Params or Spec module is forgotten.
  """
  defmacro __using__(raw) do
    {:__MODULE__, data, root} = raw
    {controller_module, _} = Keyword.get(data, :counter)

    result =
      ~r/#{root}\.([A-Za-z]+)Controller/
      |> Regex.run(Atom.to_string(controller_module))
      |> List.last()

    params_module = Module.concat(ISeeSeaWeb.Params, result)
    spec_module = Module.concat(ISeeSeaWeb.ApiSpec.Operations, result)

    quote do
      use unquote(params_module)
      use unquote(spec_module)
    end
  end
end
