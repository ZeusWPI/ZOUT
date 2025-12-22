defmodule Zout.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_handlers(:zout)

    children = [
      # Start PromEx
      Zout.PromEx,
      # Start the Ecto repository
      Zout.Repo,
      # Start the Telemetry supervisor
      ZoutWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Zout.PubSub},
      # Start the Endpoint (http/https)
      ZoutWeb.Endpoint,
      # Start a worker by calling: Zout.Worker.start_link(arg)
      # {Zout.Worker, arg}
      {Finch, name: ZoutFinch},
      Zout.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
