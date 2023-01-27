defmodule Example.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.inspect("Starting application")
    children = [
      # Starts a worker by calling: Example.Worker.start_link(arg)
      # {Example.Worker, arg}
      Supervisor.child_spec(
        {ExSseClient,
         %{
           url: "http://localhost:4040/sse",
           handler: &Example.handle_event/1,
           headers: []
         }},
        id: :sse_events
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
