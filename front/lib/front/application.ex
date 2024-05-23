defmodule Front.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FrontWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:front, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Front.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Front.Finch},
      # Start a worker by calling: Front.Worker.start_link(arg)
      # {Front.Worker, arg},
      # Start to serve requests, typically the last entry
      FrontWeb.Endpoint
    ]

    :global.register_name(:my_phoenix_server, self())
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Front.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FrontWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
