defmodule AuthorizeWeb.ConnCase do
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
  by setting `use AuthorizeWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint AuthorizeWeb.Endpoint

      use AuthorizeWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AuthorizeWeb.ConnCase
    end
  end

  setup tags do
    # Authorize.DataCase.setup_sandbox(tags)
    # {:ok, conn: Phoenix.ConnTest.build_conn()}

    Authorize.DataCase.setup_sandbox(tags)

    # Start with a fresh connection
    conn = Phoenix.ConnTest.build_conn()

    # Set up the session

    secret_key_base = Application.get_env(:authorize, AuthorizeWeb.Endpoint)[:secret_key_base]

    session_options = [
      store: :cookie,
      key: "_your_app_key",
      signing_salt: "signing_salt",
      secret_key_base: secret_key_base
    ]

    session_plug = Plug.Session.init(session_options)
    conn = Plug.Session.call(conn, session_plug)

    {:ok, conn: conn}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Authorize.Core.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Authorize.Core.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
