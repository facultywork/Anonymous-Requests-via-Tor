defmodule Tornado.Queues.RequestsQueue do
  use GenServer

  # Public API
  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def push(queue_name, request) do
    GenServer.cast(queue_name, {:push, request})
  end

  def pop(queue_name) do
    GenServer.call(queue_name, :pop)
  end

  # GenServer API
  def init(state) do
    { :ok, state }
  end

  def handle_cast({:push, request}, state) do
    state = state ++ [request]
    {:noreply, state}
  end

  def handle_call(:pop, _from , []) do
    {:reply, :empty, []}
  end

  def handle_call(:pop, _from , [head|tail]) do
    {:reply, head, tail}
  end
end