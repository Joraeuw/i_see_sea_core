defmodule ISeeSeaWeb.Params.Session do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use ISeeSeaWeb, :param

      defparams :register do
        required(:first_name, :string)
        required(:last_name, :string)
        required(:email, :string, format: :email)
        required(:password, :string, format: :password)
        required(:username, :string)
        optional(:phone_number, :string, format: :phone)
      end

      defparams :login do
        required(:email, :string, format: :email)
        required(:password, :string, format: :password)
      end
    end
  end
end
