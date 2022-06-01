defmodule ZoutWeb.Auth.OAuthStrategy do
  @moduledoc """
  OAuth2 strategy for Zeus WPI.

  This strategy hardcodes various options for ZAuth, integrating it with the
  [Überauth OAuth2 client](https://github.com/ueberauth/oauth2).

  You still need to configure some sensitive options, such as the client id and
  secret.

      config :ueberauth, ZoutWeb.Auth.OAuthStrategy,
        client_id: System.get_env("ZOUT_CLIENT_ID"),
        client_secret: System.get_env("ZOUT_CLIENT_SECRET")

  When working on this module, it might be useful to consult the OAuth2 library
  docs.

  It is based on the built-in `OAuth2.Strategy.AuthCode` strategy. This could
  be used directly, but this is nicer.

  Normally, you should not need to call this module directly; instead go through
  Überauth.
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://adams.ugent.be",
    token_url: "https://adams.ugent.be/oauth/oauth2/token",
    redirect_uri: "http://localhost:4000/auth/zeus/callback"
  ]

  @doc """
  Construct an OAuth client for use with ZAuth.
  """
  def client(opts \\ []) do
    config =
      :ueberauth
      |> Application.fetch_env!(ZoutWeb.Auth.OAuthStrategy)
      |> check_config_key_exists(:client_id)
      |> check_config_key_exists(:client_secret)

    client_opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    json_library = Ueberauth.json_library()

    OAuth2.Client.new(client_opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def authorize_url!() do
    OAuth2.Client.authorize_url!(client())
  end

  def get_token!(params \\ []) do
    OAuth2.Client.get_token!(client(), params)
  end

  @impl true
  defdelegate authorize_url(client, params), to: OAuth2.Strategy.AuthCode

  @impl true
  defdelegate get_token(client, params, headers), to: OAuth2.Strategy.AuthCode

  defp check_config_key_exists(config, key) when is_list(config) do
    unless Keyword.has_key?(config, key) do
      raise "#{inspect(key)} missing from config :ueberauth, ZoutWeb.Auth.OAuthStrategy"
    end

    config
  end

  defp check_config_key_exists(_, _) do
    raise "Config :ueberauth, ZoutWeb.Auth.OAuthStrategy is not a keyword list, as expected"
  end
end
