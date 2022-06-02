defmodule ZoutWeb.AuthController do
  @moduledoc """
  Controller responsible for authenticating users and managing sessions.

  The session management is based on Guardian and Überauth.
  """
  use ZoutWeb, :controller

  plug :store_return_address
  plug Ueberauth

  alias Zout.Accounts
  alias ZoutWeb.Auth.Guardian

  # Save the redirect address in the session.
  # The redirect path should be set by the `redirect` query parameter. Note that this says "path".
  # To prevent redirect errors (CWE-601), only the path is allowed.
  defp store_return_address(conn, _) do
    case conn.params do
      %{"from" => redirect} -> put_session(conn, :after_login_redirect, redirect)
      _ -> conn
    end
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, params) do
    # do things with the failure
    IO.inspect("FAILURE")
    IO.inspect(fails)
    render(conn, "no")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    user = Accounts.update_or_create(auth)

    redirect_url =
      case get_session(conn, :after_login_redirect) do
        nil -> Routes.page_path(conn, :index)
        url -> url
      end

    Guardian.Plug.sign_in(conn, user)
    |> delete_session(:after_login_redirect)
    |> redirect(to: redirect_url)
  end

  def logout(conn, _) do
    conn
    |> Guardian.sign_out()
    |> redirect(to: Routes.project_path(conn, :index))
  end
end
