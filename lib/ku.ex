defmodule Ku do
  use Application

  alias Ku.{Publisher, Subscriber, Log}

  defdelegate publish(routing_key, body), to: Publisher
  defdelegate publish(routing_key, body, optional), to: Publisher
  defdelegate publish(routing_key, body, optional, timeout), to: Publisher
  defdelegate subscribe(routing_key, callback), to: Subscriber
  defdelegate get_log, to: Log

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Publisher, []),
      worker(Log, []),
      worker(Subscriber.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Ku.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
