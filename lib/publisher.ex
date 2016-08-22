defmodule Publisher do
  alias Experimental.GenStage
  alias Experimental.GenStage.BroadcastDispatcher
  use GenStage

  @doc """
  Starts the publisher.
  """
  def start_link do
    GenStage.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    {:producer, {:queue.new, 0}, dispatcher: BroadcastDispatcher}
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, incoming_demand + demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
    {{:value, {from, event}}, queue} <- :queue.out(queue) do
      GenStage.reply(from, :ok)
      dispatch_events(queue, demand - 1, [event | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end


end
