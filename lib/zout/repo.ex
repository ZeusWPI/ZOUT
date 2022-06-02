defmodule Zout.Repo do
  use Ecto.Repo,
    otp_app: :zout,
    adapter: Ecto.Adapters.Postgres

end
