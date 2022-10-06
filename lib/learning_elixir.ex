defmodule LearningElixir do
  @moduledoc """
  Documentation for `LearningElixir`.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Server.Supervisor, name: Server.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
