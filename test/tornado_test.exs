defmodule TornadoTest do
  use ExUnit.Case
  doctest Tornado

  setup context do
    {:ok, request_tuple: {:get, "http://checkip.amazonaws.com/", [], "", []} }
  end

  test "sending requests with Tornado", %{request_tuple: request_tuple} do
    { :ok, tornado } = GenServer.start_link Tornado, []
    assert :ok == GenServer.cast(tornado, {:send_requests, [
        request_tuple
      ]})
  end

  test "getting responses from Tornado", %{request_tuple: request_tuple} do
    { :ok, tornado } = GenServer.start_link  Tornado, []
    GenServer.cast(tornado, {:send_requests, [
      request_tuple
    ]})
    responses = GenServer.call(tornado, :get_responses )
    [{ request_tuple, body }] = responses
    assert body =~ ~r/(\d){1,3}.(\d){1,3}.(\d){1,3}.(\d){1,3}\n/
  end

  test "getting responses from Tornado when there are no responses" do
    { :ok, tornado } = GenServer.start_link  Tornado, []
    responses = GenServer.call(tornado, :get_responses )
    assert [] == responses
  end
end
