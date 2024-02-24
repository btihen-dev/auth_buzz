defmodule Authorize.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AuthorizeWeb.Telemetry,
      Authorize.Repo,
      {DNSCluster, query: Application.get_env(:authorize, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Authorize.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Authorize.Finch},
      # Start a worker by calling: Authorize.Worker.start_link(arg)
      # {Authorize.Worker, arg},
      # Start to serve requests, typically the last entry
      AuthorizeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Authorize.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AuthorizeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
