defmodule SimpleCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies(), [name: SimpleCluster.ClusterSupervisor]]},
      SimpleCluster.Observer,
      SimpleCluster.Ping
    ]

    opts = [strategy: :one_for_one, name: LibclusterCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :"n1@127.0.0.1",
            :"n2@127.0.0.1"
          ]
        ]
      ]
    ]
  end
end
