defmodule GlobalBackgroundJob.DatabaseCleaner.Starter do
  @moduledoc """
  Spawns the database cleaner process registering it globally using :global, and monitors it,
  restarting the process again if for whatever reason it goes down.

  While starting the singleton process, `init/1` function builds its internal state and calls
  `start_and_monitor/1`.

  Finally, it implements the handle_info({:DOWN, ... callback, which will receive the corresponding message
  if the monitored process dies, calling again start_and_monitor/1 to restart it and begin the monitor loop.
  """
  use GenServer

  alias GlobalBackgroundJob.DatabaseCleaner

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    pid = start_and_monitor(opts)

    {:ok, {pid, opts}}
  end

  @impl GenServer
  def handle_info({:DOWN, _, :process, pid, _reason}, {pid, opts} = _state) do
    {:noreply, {start_and_monitor(opts), opts}}
  end

  # Takes the opts to start the database cleaner process, using {:global, name}
  # to register it. Whether spawning the database cleaner process succeeds or fails (because it has
  # already started in a different node), it takes its pid, assigns it to its internal state, and monitors it.
  defp start_and_monitor(opts) do
    pid =
      case GenServer.start_link(DatabaseCleaner, opts, name: {:global, DatabaseCleaner}) do
        {:ok, pid} ->
          pid

        {:error, {:already_started, pid}} ->
          pid
      end

    Process.monitor(pid)

    pid
  end
end
