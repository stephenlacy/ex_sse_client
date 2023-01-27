defmodule ExSseClient do
  @moduledoc """
  Elixir SSE client with reconnect.
  """

  use GenServer
  require Logger

  def start_link(%{url: url, handler: handler, headers: headers}) do
    GenServer.start_link(__MODULE__, url: url, handler: handler, headers: headers)
  end

  def init(url: url, handler: handler, headers: headers) do
      Logger.info("Connecting to stream #{url}")

      try do
        HTTPoison.get!(url, headers, recv_timeout: :infinity, stream_to: self())
      rescue
        e ->
          # Sleep for 1s and restart
          :timer.sleep(1000)
          raise e
      end

    {:ok, %{handler: handler, url: url, headers: headers}}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    # try/rescue prevents the SSE connection from exiting when bad packets are parsed
    try do
      state.handler.(chunk)
    rescue
      e -> e
    end

    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncStatus{} = _status, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{} = _headers, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncEnd{} = _status, _state) do
    # on end crash/restart
    raise "AsyncEnd called - restarting"
  end

  def handle_info(%HTTPoison.Error{} = _status, _state) do
    # on end crash/restart
    raise "AsyncError called - restarting"
  end

  def handle_info(_payload, state) do
    {:noreply, state}
  end
end
