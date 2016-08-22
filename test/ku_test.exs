defmodule KuTest do
  use ExUnit.Case
  alias Experimental.GenStage
  alias Experimental.GenStage.BroadcastDispatcher
  doctest Ku

  test "should start as register Publisher process" do
    publisher = Process.whereis(Publisher)
    assert publisher
    %GenStage{type: :producer,
              dispatcher_mod: BroadcastDispatcher} = :sys.get_state(publisher)
  end

  test "subscribe should start Subscriber as a consumer to Publisher" do
    routing_key = ~r/^foo\.bar$/
    callback = &IO.inspect/1

    publisher_state = :sys.get_state Publisher
    assert length(Map.keys publisher_state.consumers) == 0

    {:ok, subscriber} = Publisher.subscribe routing_key, callback
    subscriber_state = :sys.get_state subscriber
    assert subscriber_state.type == :consumer
    assert subscriber_state.state.callback == callback
    assert subscriber_state.state.routing_key == routing_key

    publisher_state = :sys.get_state Publisher
    assert length(Map.keys publisher_state.consumers) == 1
  end
end
