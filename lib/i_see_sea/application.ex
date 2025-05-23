defmodule ISeeSea.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ISeeSeaWeb.Telemetry,
      ISeeSea.Repo,
      # {DNSCluster, query: Application.get_env(:i_see_sea, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ISeeSea.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ISeeSea.Finch},
      {Oban, Application.fetch_env!(:i_see_sea, Oban)},
      # Start a worker by calling: ISeeSea.Worker.start_link(arg)
      # {ISeeSea.Worker, arg},
      # Start to serve requests, typically the last entry
      ISeeSeaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ISeeSea.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ISeeSeaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
