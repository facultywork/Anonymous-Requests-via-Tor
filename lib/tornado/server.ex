defmodule Tornado.Server do
  use GenServer
  import Supervisor.Spec

  # Public API
  def start_link(state,  opts \\ []) do
    GenServer.start_link __MODULE__, state, opts
  end

  def send_requests(requests) do
    GenServer.cast(__MODULE__, {:send_requests, requests})
  end

  def get_responses do
    GenServer.call(__MODULE__, :get_responses )
  end

  # GenServer API
  def init(state) do
    { :ok, state }
  end

  def handle_cast({:send_requests, requests}, state) do
    #state = state ++ [{requests, "127.0.0.1\n"}]
    Enum.map(requests, fn (request) ->
      {method, url, headers, payload, options} = request
      domain = domain_for_url url
      identifier = identifier_for_domain domain
      queue = queue_for_identifier identifier
      scheduler = scheduler_for_identifier identifier
      if queue |> Process.whereis do
        Tornado.Queues.RequestsQueue.push(queue, request)
      else
        queue_process = worker(Tornado.Queues.RequestsQueue,
          [
            [],
            [name: queue]
          ],
          [id: queue]
        )
        scheduler_process = worker(Tornado.DomainScheduler,
          [
            queue,
            [name: scheduler]
          ],
          [id: scheduler]
        )
        {:ok, queue_pid} = Supervisor.start_child(Tornado.Supervisors.RequestsQueuesSupervisor, queue_process)
        Supervisor.start_child(Tornado.Supervisors.DomainSchedulersSupervisor, scheduler_process)
        Tornado.Queues.RequestsQueue.push(queue, request)
        Tornado.DomainScheduler.schedule_requests(scheduler)
        #GenServer.cast(queue_pid, {:push, request})
      end
    end)
    # for each request in requests
    # get it's domain for URI
    # if we have a scheduler for that URI
      # send the request to it
    # else 
      # spawn a new scheduler and
        # a request queue
        # both with name containing the URI 
      # supervise the newly created
        # genservers with 
        # DomainSchedulersSupervisor
        # and RequestsQueuesSupervisor
    {:noreply, state }
  end

  def handle_call(:get_responses, _from, state) do
    response = Tornado.Queues.ResponsesQueue.pop()
    {:reply, response, state}
  end

  # Private 

  defp domain_for_url(url) do
    uri = URI.parse(url)
    if uri.scheme |> is_nil() do
      uri = URI.parse("http://#{url}")
    end
    host = uri.host |> String.downcase
    if host |> String.starts_with?("www.") do
      host = host |> String.slice(4..-1)  
    end
    host
  end

  def identifier_for_domain(domain) do
    domain
    |> String.split(".")
    |> Enum.map(fn(x) -> "URL" <> x end)
    |> Enum.join(".")
  end

  defp queue_for_identifier(identifier) do
    Module.concat(Tornado.Queues.RequestsQueue, identifier)
  end

  defp scheduler_for_identifier(identifier) do
    Module.concat(Tornado.DomainScheduler, identifier)
  end
end
