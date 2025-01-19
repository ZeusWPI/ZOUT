defmodule ZoutWeb.AuthController do
  @moduledoc """
  Controller for managing users.

  Note that the login calls are intercepted by Überauth, and thus not present
  in this controller.

  The session management is based on Guardian and Überauth. When a user logs in,
  we store the user's ID in a cookie.

  This controller also functions as the error handler for Guardian.
  """
  use ZoutWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

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

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    # do things with the failure
    IO.inspect("FAILURE")
    IO.inspect(fails)
    render(conn, "no")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = Accounts.update_or_create!(auth)

    redirect_url =
      case get_session(conn, :after_login_redirect) do
        nil -> ~p"/"
        url -> url
      end

    Guardian.Plug.sign_in(conn, user)
    |> delete_session(:after_login_redirect)
    |> redirect(to: redirect_url)
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: ~p"/projects")
  end

  @impl true
  def auth_error(conn, {:unauthenticated, reason}, _opts) do
    IO.inspect("Unauthenticated due to")
    IO.inspect(reason)
    redirect(conn, to: ~p"/auth/zeus?from=#{current_path(conn)}")
  end

  # Handle invalid tokens. This error needs special attention: if we do nothing,
  # the user cannot login again, and will continue to see an error until they
  # manually clear their cookies (since the authentication plug intercepts all
  # requests, including those for logging out). By manually logging them out,
  # we can prevent this.
  @impl true
  def auth_error(conn, {:invalid_token, _reason}, _opts) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:error, "Ongeldige token, meld opnieuw aan.")
    |> redirect(to: ~p"/projects")
  end

  @impl true
  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    conn
    |> put_resp_content_type("text/plain")
    |> Guardian.Plug.sign_out()
    |> send_resp(401, body)
  end
end
