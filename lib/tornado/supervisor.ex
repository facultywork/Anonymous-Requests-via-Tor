defmodule Tornado.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__,[], [name: Tornado.Supervisor])
  end

  def init([]) do
    children = [
      worker(Tornado.Server, [[], [name: Tornado.Server]]),
      worker(Tornado.Supervisors.CircuitClientsSupervisor, 
        [[],[name: Tornado.Supervisors.CircuitClientsSupervisor]]
      ),
      worker(Tornado.Supervisors.RequestsQueuesSupervisor,
        [[],[name: Tornado.Supervisors.RequestsQueuesSupervisor]]
      ),
      worker(Tornado.Supervisors.DomainSchedulersSupervisor,
        [[],[name: Tornado.Supervisors.DomainSchedulersSupervisor]]
      ),
      worker(Tornado.Queues.ResponsesQueue, [[], [name: Tornado.Queues.ResponsesQueue]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end