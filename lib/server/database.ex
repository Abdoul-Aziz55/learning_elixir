defmodule Server.Database do
  use GenServer

  def lookup(db, key) do
    case :ets.lookup(db, key) do
      [] -> :error
      [{_, val}] -> {:ok, val}
    end
  end

  def match(db, criteria) do
    :ets.select(db, criteria)
      |> Enum.map(fn {_, val} -> val end)
  end




  @impl true
  def init(:ok) do
    {:ok, :ets.new(:table, [:set])}
  end

  @impl true
  def handle_call({:read, key}, _from, db) do
    case lookup(db, key) do
      :error -> {:reply, :error, db}
      {:ok, val} -> {:reply, {:ok, val}, db}
    end
  end

  @impl true
  def handle_call({:search, criterias}, _from, db) do
    result =
      Enum.map(criterias, fn {key, val} ->
        criteria = [{{:_, %{~s(#{key}) => :"$1"}}, [{:==, :"$1", val}], [:"$_"]}]
        match(db, criteria)
      end)
        |> List.flatten()
        |> Enum.uniq()

    {:reply, {:ok, result}, db}
  end

  @impl true
  def handle_cast({:update, {key, newVal}}, db) do
    :ets.insert(db, {key, newVal})
    {:noreply, db}
  end

  @impl true
  def handle_cast({:create, {key, val}}, db) do
    :ets.insert_new(db, {key, val})
    {:noreply, db}
  end

  @impl true
  def handle_cast({:delete, key}, db) do
    :ets.delete(db, key)
    {:noreply, db}
  end


  ## client API
  def start_link(ops) do
    GenServer.start_link(__MODULE__, :ok, ops)
  end

  @doc """
  creates a new value assigned to a given key in the database
  """
  def create(server, key, val) do
    GenServer.cast(server, {:create, {key, val}})
  end

  @doc """
  reads a value in a database given the key.
  Returns `{:ok, value}` if the key exists, `:error` otherwise.
  """
  def read(server, key) do
    GenServer.call(server, {:read, key})
  end

  @doc """
  updates a value assigned to a `key` in the database if the `key` exists
  creates a new `key` with the `value` in the database if the `key` does not exist
  """
  def update(server, key, newVal) do
    GenServer.cast(server, {:update, {key, newVal}})
  end

  @doc """
  Deletes a `value` from the database given its `key`
  """
  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  @doc """
  Searches a value in a data base
  """
  def search(server, criteria) do
    GenServer.call(server, {:search, criteria})
  end

end
