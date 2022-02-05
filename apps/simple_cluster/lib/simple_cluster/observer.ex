defmodule SimpleCluster.Observer do
  use GenServer
  require Logger

  def start_link(_state) do
    state = %{last_updated: DateTime.utc_now()}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  init a process, finding the most recent updated state and returning that
  as this processes current state
  """
  @impl GenServer
  def init(state) do
    :net_kernel.monitor_nodes(true)

    Logger.info(%{
      message: "init with state -> #{inspect(state)}",
      module: __MODULE__
    })

    most_recent_state =
      nodes_states()
      |> Enum.sort_by(& &1.last_updated, {:desc, DateTime})
      |> List.first()

    {:ok, most_recent_state || state}
  end

  @impl GenServer
  def handle_info({:nodedown, node}, state) do
    # A node left the cluster
    log_message(node, "Node DOWN", state)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodeup, node}, state) do
    # A new node joined the cluster
    log_message(node, "Node UP", state)

    {:noreply, state}
  end

  def log_message(node, message, state) do
    Logger.info(%{
      module: __MODULE__,
      node: node,
      message: message,
      state: state
    })
  end

  def insert(data) do
    GenServer.call({__MODULE__, node()}, {:insert, data})
  end

  def state() do
    GenServer.call({__MODULE__, node()}, :state)
  end

  defp update_nodes(state) do
    Node.list()
    |> Enum.map(&GenServer.call({__MODULE__, &1}, {:update_state, state}))
    |> Logger.info()
  end

  defp nodes_states() do
    Node.list()
    |> case do
      [] ->
        Logger.info("No other nodes in cluster")
        []

      nodes ->
        nodes
        |> IO.inspect(label: "Other Nodes")
        |> Enum.map(&GenServer.call({__MODULE__, &1}, :state))
        |> IO.inspect(label: "Other Nodes States")
    end
  end

  @doc """
  Takes a new map and merges into the most recent updated map from the cluster
    ## Examples

    ```
    iex> from = self()
    ...> state = %{a: 123}
    ...> SimpleCluster.Observer.handle_call({:insert, %{new: :insert}}, from, state)
    {:reply, :insert_success, %{a: 123, new: :insert}}
    ```

    ```
    iex> from = self()
    ...> state = %{a: 123}
    ...> SimpleCluster.Observer.handle_call({:insert, [new: :insert]}, from, state)
    {:reply, :insert_error, %{a: 123}}
    ```
  """

  @impl true
  def handle_call({:insert, updates}, _from, state) do
    try do
      new_state = Map.merge(state, updates)

      update_nodes(new_state)
      # throw("dang")

      {:reply, :insert_success, new_state}
    rescue
      BadMapError ->
        {:reply, :insert_error, state}
    catch
      thrown_msg ->
        IO.puts("Caught throw #{inspect(thrown_msg)}")
        {:reply, :insert_error, state}
    end
  end

  @impl true
  def handle_call(:state, _from, state) do
    Logger.info("retrieving state")

    {:reply, state, state}
  end

  @impl true
  def handle_call({:update_state, new_state}, _from, _old_state) do
    Logger.info("update state on #{node()}")

    # key_or_state = Map.get(state, key, state)

    {:reply, new_state, new_state}
  end
end
