defmodule Ku.Log do
  @moduledoc """
  Log subscribe to Publisher and keep every events in state.
  """
  alias Experimental.GenStage
  alias Ku.Publisher
  use GenStage

  def start_link do
    GenStage.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    {:consumer, [], subscribe_to: [Publisher]}
  end

  @doc """
  Get event-logs
  """
  def get_log do
    GenStage.call __MODULE__, :get_log
  end

  def handle_events(events, _from, state) do
    new_state = Enum.concat(events, state)
    {:noreply, [], new_state}
  end

  def handle_call(:get_log, from, state) do
    GenStage.reply(from, Enum.reverse state)
      {:noreply, [], state}
  end

end
