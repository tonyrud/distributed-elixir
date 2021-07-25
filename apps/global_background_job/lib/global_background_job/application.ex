defmodule GlobalBackgroundJob.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies(), [name: GlobalBackgroundJob.ClusterSupervisor]]},
      {GlobalBackgroundJob.DatabaseCleaner.Starter, [timeout: :timer.seconds(5)]}
    ]

    opts = [strategy: :one_for_one, name: GlobalBackgroundJob.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      background_job: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]
  end
end
