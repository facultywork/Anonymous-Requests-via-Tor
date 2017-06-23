defmodule Tornado do
  use Application

  def start(_type, _args) do
    Tornado.Supervisor.start_link()
  end
end