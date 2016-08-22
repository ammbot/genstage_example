defmodule Subscriber do
  alias Experimental.GenStage
  use GenStage

  defstruct routing_key: nil, callback: nil

  @doc """
  Starts the subscriber.
  """
  def start_link(routing_key, callback) do
    GenStage.start_link __MODULE__, {routing_key, callback}
  end

  def init({routing_key, callback}) do
    state = %__MODULE__{routing_key: routing_key, callback: callback}
    {:consumer, state, subscribe_to: [Publisher]}
  end

  def handle_events(events, _from, state) do
    {:noreply, [], state}
  end
end

