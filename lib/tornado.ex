defmodule Tornado do
	use GenServer

  def start_link(state, opts \\ []) do
    GenServer.start_link Tornado, state
  end

  def init(state) do
    { :ok, state }
  end

  def handle_call(:get_responses, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:send_requests, requests}, state) do
    state = state ++ [{requests, "127.0.0.1\n"}]
    {:noreply, state }
  end
end
