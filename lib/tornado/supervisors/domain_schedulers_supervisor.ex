defmodule Tornado.Supervisors.DomainSchedulersSupervisor do
  use Supervisor

  def start_link(state, opts \\ []) do
    Supervisor.start_link(__MODULE__, state, opts)
  end

  def init([]) do
    children = []

    supervise(children, strategy: :one_for_one)
  end
end