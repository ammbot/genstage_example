defmodule Ku.Subscriber.Supervisor do
  @moduledoc """
  A dynamic supervisor that will
  spawn subscriber when someone calling Ku.Publisher.subcribe/3.
  """
  alias Experimental.DynamicSupervisor
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link __MODULE__, [], name: __MODULE__
  end

  def init([]) do
    children = [
      worker(Ku.Subscriber, [])
    ]
    {:ok, children, strategy: :one_for_one}
  end
end
