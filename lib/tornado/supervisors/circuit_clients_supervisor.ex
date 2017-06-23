defmodule Tornado.Supervisors.CircuitClientsSupervisor do
  use Supervisor
  import Tornado.Utils.Namer

  def start_link(state, opts \\ []) do
    Supervisor.start_link(__MODULE__, state, opts)
  end

  def get_children do
    initial_port = Application.get_env :tornado, :initial_port
    clients = Application.get_env :tornado, :circuit_clients
    for child <- 0..(clients-1) do
      port = child + initial_port
      module_name = circuit_client_for(port)

      pool = do_pool_for_port(port)
      do_start_pool(pool)

      worker(Tornado.CircuitClient,
        [
          %{port: port, pool: pool },
          [name: module_name]
        ],
        [id: module_name]
      )
    end
  end

  def init([]) do
    children = get_children

    supervise(children, strategy: :one_for_one)
  end

  defp do_pool_for_port port do
    "port#{port}" |> String.to_atom
  end

  defp do_start_pool pool do
    options = [{:timeout, 150000},{:max_connections, 100}]
    :hackney_pool.start_pool(pool, options)
  end
end