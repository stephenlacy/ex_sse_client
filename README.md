# ExSseClient
> Elixir SSE client with reconnect.

## Installation


```elixir
def deps do
  [
    {:ex_sse_client, "https://github.com/stevelacy/ex_sse_client.git"}
  ]
end
```

### Usage

`application.ex`
```elixir

# ...

def start(_type, _args) do
Logger.add_backend(Sentry.LoggerBackend)

children = [
  Supervisor.child_spec(
    {ExSseClient,
    %{
      url: "https://example.com/events",
      handler: &MyApp.SSEHandler.handle_event/1,
      headers: MyApp.SSEHandler.headers()
    }},
    id: :sse_events
  )
]

# ...
end

```
