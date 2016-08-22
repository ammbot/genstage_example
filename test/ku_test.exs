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
  doctest Ku

  test "should start as register Publisher process" do
    publisher = Process.whereis(Publisher)
    assert publisher
    %GenStage{type: :producer,
              dispatcher_mod: BroadcastDispatcher} = :sys.get_state(publisher)
  end

  test "publish deliver to correct subscriber" do

    Publisher.subscribe ~r/^foo\.bar$/, &MyModule.do_it/1
    Publisher.subscribe ~r/^foo\.*/, &MyOtherModule.also_do_it/1

    Publisher.publish "foo.bar", %{bar: "baz"}, %{optional: "metadata object", to: self}
    Publisher.publish "foo.lala", %{bam: "boo"}, %{optional: "metadata object", to: self}
    Publisher.publish "unhandled_key", %{boom: "biim"}, %{optional: "metadata object", to: self}

    assert_receive %{body: %{bar: "baz"}, metadata: %{optional: "metadata object"}, from: MyModule.Doit}
    assert_receive %{body: %{bar: "baz"}, metadata: %{optional: "metadata object"}, from: MyOtherModule.AlsoDoIt}
    refute_receive %{body: %{bam: "boo"}, metadata: %{optional: "metadata object"}, from: MyModule.Doit}
    assert_receive %{body: %{bam: "boo"}, metadata: %{optional: "metadata object"}, from: MyOtherModule.AlsoDoIt}

    refute_receive %{body: %{boom: "biim"}, metadata: %{optional: "metadata object"}, from: MyModule.Doit}
    refute_receive %{body: %{boom: "biim"}, metadata: %{optional: "metadata object"}, from: MyOtherModule.AlsoDoIt}
  end
end
