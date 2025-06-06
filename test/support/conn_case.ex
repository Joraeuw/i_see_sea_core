defmodule ISeeSeaWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ISeeSeaWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias ISeeSea.DB.Models.Role

  using do
    quote do
      # The default endpoint for testing
      @endpoint ISeeSeaWeb.Endpoint

      use ISeeSeaWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import ISeeSea.Factory
      import Phoenix.ConnTest
      import ISeeSeaWeb.ConnCase
      alias ISeeSeaWeb.Router.Helpers, as: Routes
    end
  end

  setup _tags do
    import ISeeSea.Factory

    alias ISeeSea.Authentication.Tokenizer

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ISeeSea.Repo)

    api_spec = ISeeSeaWeb.ApiSpec.spec()

    conn = Phoenix.ConnTest.build_conn()

    user = insert!(:user)
    {:ok, %Role{id: admin_role_id}} = Role.get(:admin)
    admin = insert!(:user, role_id: admin_role_id)

    {:ok, token, _claims} = Tokenizer.encode_and_sign(user, %{id: user.id})
    conn_user = Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> token)

    {:ok, token, _claims} = Tokenizer.encode_and_sign(admin, %{id: admin.id})
    conn_admin = Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> token)

    {:ok,
     conn: Phoenix.ConnTest.build_conn(),
     conn_user: conn_user,
     conn_end_user: conn_user,
     user: user,
     admin: admin,
     conn_admin: conn_admin,
     end_user: user,
     api_spec: api_spec}
  end
end
