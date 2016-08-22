defmodule Subscriber do
  alias Experimental.GenStage
  use GenStage

  defstruct routing_key: nil, callback: nil

  @doc """
  Starts the subscriber.
  """
  def start_link(key, callback) do
    GenStage.start_link __MODULE__, {key, callback}
  end

  def init({key, callback}) do
    state = %__MODULE__{routing_key: key, callback: callback}
    {:consumer, state, subscribe_to: [Publisher]}
  end

  def handle_events(events, from, state) do
    for event <- events do
      if Regex.match?(state.routing_key, event.routing_key) do
        apply(state.callback, [event])
      end
    end
    {:noreply, [], state}
  end
end

