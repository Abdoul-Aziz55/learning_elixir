defmodule HelloPort do
  use GenServer

  @impl true
  def init({cmd,init,opts}) do
    port = Port.open({:spawn,'#{cmd}'}, [:binary,:exit_status, packet: 4] ++ opts)
    send(port,{self(),{:command,:erlang.term_to_binary(init)}})
    {:ok,port}
  end

  @impl true
  def handle_call(term,_reply_to,port) do
    send(port,{self(),{:command,:erlang.term_to_binary(term)}})
    res = receive do {^port,{:data,b}}->:erlang.binary_to_term(b) end
    {:reply,res,port}
  end

  @impl true
  def handle_cast(term,port) do
    send(port,{self(),{:command,:erlang.term_to_binary(term)}})
    {:noreply,port}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, {"node hello.js", 0, cd: "lib/server"}, name: Hello)
  end

  def call(cmd) do
    GenServer.call Hello, cmd
  end

  def cast(term) do
    GenServer.cast Hello, term
  end

end
