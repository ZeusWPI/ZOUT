import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :zout, Zout.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "zout_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :zout, ZoutWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KFyksyvSAY4iOL14fwoHTG6OI18ZtAG7O3nCVXf8WQyv+OaW9jJG28L2ML3QAKyO",
  server: false

# In test we don't send emails.
config :zout, Zout.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Guardian token for cookies
config :zout, ZoutWeb.Auth.Guardian,
  issuer: "zout",
  secret_key: "S75heLj8yJOXPohixmJdpLotLbVYVBMwYXXI5xxlD7VWklROQooxoaKVMqNeXpHr"
