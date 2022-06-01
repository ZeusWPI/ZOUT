defmodule ZoutWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :zout,
    error_handler: ZoutWeb.Auth.ErrorHandler,
    module: ZoutWeb.Auth.Guardian

  # Try using the refresh token for a fresh access token, if necessary.
  plug Guardian.Plug.VerifyCookie

  # Load the user if either of the verifications worked.
  # This hits the database. Try to avoid if unnecessary
  plug Guardian.Plug.LoadResource, allow_blank: true
end
