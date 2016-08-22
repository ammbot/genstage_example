defmodule Ku.Subscriber do
  @moduledoc """
  Subscriber will receive event from Publisher
  and if routing_key is matched, callback will be triggered.
  """
  alias Experimental.{DynamicSupervisor, GenStage}
  alias Ku.Publisher
  use GenStage
  require Logger

  defstruct routing_key: nil, callback: nil

  @doc """
  Starts the subscriber.
  """
  def start_link(key, callback) do
    GenStage.start_link __MODULE__, {key, callback}
  end

  @doc """
  Subscribe new pattern

  ## Example

      Ku.subscribe ~r/^foo\.bar$/, &MyModule.do_it/1
  """
  @spec subscribe(Regex.t, fun()) :: term
  def subscribe(key, callback) do
    DynamicSupervisor.start_child(Ku.Subscriber.Supervisor, [key, callback])
  end

  def init({key, callback}) do
    state = %__MODULE__{routing_key: key, callback: callback}
    {:consumer, state, subscribe_to: [Publisher]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      if Regex.match?(state.routing_key, event.routing_key) do
        apply(state.callback, [event])
      end
    end
    {:noreply, [], state}
  end
end

