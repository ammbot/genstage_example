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
end
