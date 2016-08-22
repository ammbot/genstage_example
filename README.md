# Example of GenStage for pub/sub system

# API

## Installation

First, add HTTPoison to your `mix.exs` dependencies:

```elixir
def deps do
  [{:ku, "~> 0.1.0"}]
  end
  ```

  and run `$ mix deps.get`. Now, list the `:ku` application as your
  application dependency:

  ```elixir
  def application do
    [applications: [:ku]]
    end
    ```

## Subscribe a function to a regex pattern
```elixir
Ku.subscribe ~r/^foo\.bar$/, &MyModule.do_it/1          # Matches only "foo.bar" events.
Ku.subscribe ~r/^foo\.*/, &MyOtherModule.also_do_it/1   # Matches all "foo. ..." events.
```

## Publish a message
```elixir
Ku.publish routing_key, message_body, optional_metadata
```

Deliver to both `MyModule.do_it/1` & `MyOtherModule.also_do_it/1`
```elixir
Ku.publish "foo.bar", %{bar: "baz"}, %{optional: "metadata object"}
```

Deliver only to `MyOtherModule.also_do_it/1`
```elixir
Ku.publish "foo.lala", %{bar: "baz"}, %{optional: "metadata object"}
```

Deliver to nothing (no matching bindings)
```elixir
Ku.publish "unhandled_key", %{bar: "baz"}, %{optional: "metadata object"}
```
