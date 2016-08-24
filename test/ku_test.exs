defmodule MyModule do
  def do_it(message) do
    message = Map.put message, :from, MyModule.Doit
    send message.metadata.to, message
  end
end

defmodule MyOtherModule do
  def also_do_it(message) do
    message = Map.put message, :from, MyOtherModule.AlsoDoIt
    send message.metadata.to, message
  end
end

defmodule KuTest do
  use ExUnit.Case
  alias Experimental.GenStage
  alias Experimental.GenStage.BroadcastDispatcher
  alias Ku.Publisher

  test "should start as register Publisher process" do
    publisher = Process.whereis(Publisher)
    assert publisher
    %GenStage{type: :producer,
              dispatcher_mod: BroadcastDispatcher} = :sys.get_state(publisher)
  end

  test "publish deliver to correct subscriber" do

    Ku.subscribe "foo.bar", &MyModule.do_it/1
    Ku.subscribe "foo.*", &MyOtherModule.also_do_it/1

    Ku.publish "foo.bar", %{bar: "baz"}, %{optional: "metadata object", to: self}
    Ku.publish "foo.lala", %{bam: "boo"}, %{optional: "metadata object", to: self}
    Ku.publish "unhandled_key", %{boom: "biim"}, %{optional: "metadata object", to: self}

    assert_receive %{body: %{bar: "baz"}, metadata: %{optional: "metadata object"}, from: MyModule.Doit}
    assert_receive %{body: %{bar: "baz"}, metadata: %{optional: "metadata object"}, from: MyOtherModule.AlsoDoIt}
    refute_receive %{body: %{bam: "boo"}, metadata: %{optional: "metadata object"}, from: MyModule.Doit}
    assert_receive %{body: %{bam: "boo"}, metadata: %{optional: "metadata object"}, from: MyOtherModule.AlsoDoIt}

    refute_receive %{body: %{boom: "biim"}, metadata: %{optional: "metadata object"}, from: MyModule.Doit}
    refute_receive %{body: %{boom: "biim"}, metadata: %{optional: "metadata object"}, from: MyOtherModule.AlsoDoIt}
  end

  test "logger should keep log and can retrieve it" do
    Ku.publish "some_key", %{amm: "bot"}
    assert %Publisher.Msg{body: %{amm: "bot"},
                          metadata: %{},
                          routing_key: "some_key"} in Ku.get_log
  end

  test "match_routing_key" do
    assert Ku.Subscriber.match_routing_key "foo.bar", "foo.bar"
    refute Ku.Subscriber.match_routing_key "foo.baz", "foo.bar"

    assert Ku.Subscriber.match_routing_key "foo.*", "foo.lala"
    refute Ku.Subscriber.match_routing_key "foo.*", "bar.baz"

    assert Ku.Subscriber.match_routing_key "foo.*.bar", "foo.foo.bar"
    refute Ku.Subscriber.match_routing_key "foo.*.bar", "foo.bar.baz"
  end
end
