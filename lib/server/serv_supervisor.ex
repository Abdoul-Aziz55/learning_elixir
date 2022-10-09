defmodule Server.Supervisor do
  use Supervisor

  def start_link(_) do
    {:ok, _} = Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do


    children = [
      {Server.Database, name: Server.Database},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
