defmodule Ku do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Publisher, [])
    ]

    opts = [strategy: :one_for_one, name: Ku.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
