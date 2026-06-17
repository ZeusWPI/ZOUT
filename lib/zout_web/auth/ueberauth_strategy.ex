defmodule ZoutWeb.Auth.UeberauthStrategy do
  @moduledoc """
  Provides an Ueberauth strategy for authenticating with Zeus.
  """
  use Ueberauth.Strategy,
    # Oops
    ignores_csrf_attack: true,
    oauth2_module: ZoutWeb.Auth.OAuthStrategy

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles the initial redirect to the ZAuth authentication page.
  """
  @impl true
  def handle_request!(conn) do
    redirect!(conn, ZoutWeb.Auth.OAuthStrategy.authorize_url!())
  end

  @doc """
  Handles the callback from ZAuth. When there is a failure from ZAuth the failure is included in the
  `ueberauth_failure` struct. Otherwise the information returned from ZAuth is returned in the `Ueberauth.Auth` struct.
  """
  @impl true
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    client = ZoutWeb.Auth.OAuthStrategy.get_token!(code: code)
    conn = put_private(conn, :zeus_token, client.token)

    fetch_user(conn, client)
  end

  @impl true
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @impl true
  def handle_cleanup!(conn) do
    conn
    |> put_private(:zeus_user, nil)
    |> put_private(:zeus_token, nil)
  end

  @impl true
  def uid(conn) do
    conn.private.zeus_user["id"]
  end

  @impl true
  def credentials(conn) do
    token = conn.private.zeus_token

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: nil,
      scopes: []
    }
  end

  @impl true
  def info(conn) do
    user = conn.private.zeus_user

    %Info{
      name: user["full_name"],
      nickname: user["username"]
    }
  end

  @impl true
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.zeus_token,
        user: conn.private.zeus_user,
        admin: conn.private.zeus_user["admin"],
        roles: conn.private.zeus_user["roles"]
      }
    }
  end

  defp fetch_user(conn, client) do
    case OAuth2.Client.get(client, "/current_user") do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :zeus_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])

      {:error, %OAuth2.Response{body: %{"message" => reason}}} ->
        set_errors!(conn, [error("OAuth2", reason)])

      {:error, _} ->
        set_errors!(conn, [error("OAuth2", "unknown error")])
    end
  end
end
