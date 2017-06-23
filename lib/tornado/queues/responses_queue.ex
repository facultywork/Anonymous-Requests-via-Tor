defmodule Tornado.Queues.ResponsesQueue do
  use GenServer

  # Public API
  def start_link(state, opts \\[]) do
    GenServer.start_link(__MODULE__, state, opts)
  end
  
  def push(response) do
    GenServer.cast(__MODULE__, {:push, response})
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  # GenServer API
  def init(queue) do
    {:ok, queue}
  end

  def handle_cast({:push, response}, queue) do
    queue = queue ++ [response]
    {:noreply, queue}
  end

  def handle_call(:pop, _from , []) do
    {:reply, :empty, []}
  end

  def handle_call(:pop, _from, [head|tail]) do
    {:reply, head, tail}
  end
end