defmodule Publisher do
  alias Experimental.GenStage
  alias Experimental.GenStage.BroadcastDispatcher
  use GenStage

  defmodule Msg do
    defstruct routing_key: nil, body: %{}, metadata: %{}
  end

  @doc """
  Starts the publisher.
  """
  def start_link do
    GenStage.start_link __MODULE__, :ok, name: __MODULE__
  end

  @doc """
  Publish a message
  """
  @spec publish(Regex.t, Map.t, Map.t, non_neg_integer()) :: term
  def publish(key, body, optional \\ %{}, timeout \\ 5000) do
    msg = {:publish, key, body, optional}
    GenStage.call __MODULE__, msg, timeout
  end

  @doc """
  Subscribe new pattern
  """
  @spec subscribe(Regex.t, fun()) :: term
  def subscribe(key, callback) do
    Subscriber.start_link key, callback
  end

  def init(:ok) do
    {:producer, {:queue.new, 0}, dispatcher: BroadcastDispatcher}
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, incoming_demand + demand, [])
  end

  def handle_call({:publish, key, body, optional}, from, {queue, demand}) do
    msg = %Msg{routing_key: key, body: body, metadata: optional}
    dispatch_events(:queue.in({from, msg}, queue), demand, [])
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
