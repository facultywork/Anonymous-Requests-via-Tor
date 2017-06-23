defmodule Tornado.CircuitClient do
  use GenServer

  # Public API
  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def send_request(circuit_client, request) do
    GenServer.cast(circuit_client, {:send_request, request})
  end

  # GenServer API
  def init(state) do
    { :ok, state }
  end

  def handle_cast({:send_request, request}, state) do
    {method, url, _, _, _} = request
    response = do_socks_request(state, method, url)
    
    parsed_response = case response do
      {:ok, status, headers, clientReference} ->
        body = clientReference |> :hackney.body
        %{
          status: status,
          headers: headers,
          body: body
        }
      {:error, reason} ->
        %{
          error: reason
        } 
    end
    do_enqueue_request_response(%{request: request, response: parsed_response})
    {:noreply, state}
  end

  def do_socks_request(state, method \\ :get, url \\ "http://checkip.amazonaws.com/",
                     headers \\ [], payload \\ "") do
    options = [{:pool, state.pool}, {:proxy, {:socks5, :localhost, state.port}}]
    :hackney.request(method, url, headers, payload, options )
  end

  defp do_enqueue_request_response(request_response) do
    Tornado.Queues.ResponsesQueue.push(request_response)
  end
end