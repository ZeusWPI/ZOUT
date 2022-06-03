defmodule ZoutWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :zout,
    error_handler: ZoutWeb.AuthController,
    module: ZoutWeb.Auth.Guardian

  # Get the token from the cookie.
  plug Guardian.Plug.VerifySession, refresh_from_cookie: true
  # Load the user if a token was found.
  plug Guardian.Plug.LoadResource, allow_blank: true
end
