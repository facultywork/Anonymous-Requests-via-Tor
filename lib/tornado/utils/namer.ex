defmodule Tornado.Utils.Namer do
  
  def circuit_client_for(port) do
    port_string = port |> Integer.to_string
    port_string = "Port" <> port_string
    Module.concat(Tornado.CircuitClient, port_string)
  end
end