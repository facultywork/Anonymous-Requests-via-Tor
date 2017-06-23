defmodule Tornado.DomainScheduler do
  use GenServer
  import Tornado.Utils.Namer

  # Public API
  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def schedule_requests(scheduler) do
    GenServer.cast(scheduler, :schedule_requests)
  end

  # GenServer API
  def init(queue) do
    { :ok, queue }
  end

  def handle_cast(:schedule_requests, queue) do
    initial_port = Application.get_env :tornado, :initial_port
    circuit_clients = Application.get_env(:tornado, :circuit_clients)
    delay_for_domain = Application.get_env(:tornado, :delay_for_domain)
    do_schedule_requests(initial_port, circuit_clients, delay_for_domain, queue)
  end

  # Private
  defp do_schedule_requests(initial_port, circuits, delay, queue) do
    Enum.map(1..circuits, fn(circuit_number) ->
      request = Tornado.Queues.RequestsQueue.pop(queue)
      unless request == :empty do
        port = initial_port + circuit_number
        circuit_client = circuit_client_for(port)
        Tornado.CircuitClient.send_request(circuit_client, request)
      end
    end)
    :timer.sleep delay
    do_schedule_requests(initial_port, circuits, delay, queue)
  end
end