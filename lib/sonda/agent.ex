defmodule Sonda.Agent do
  use Agent

  @spec start_link(
          config :: {Sonda.Sink.t(), (() -> NaiveDateTime.t())},
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link({sink, clock_now}, opts) do
    Agent.start_link(fn -> {sink, clock_now} end, opts)
  end

  @spec record(
          server :: Agent.agent(),
          signal :: Sonda.signal(),
          data :: any()
        ) ::
          :ok
  def record(server, signal, data) do
    Agent.update(server, fn {sink, clock_now} ->
      timestamp = clock_now.()
      sink = Sonda.Sink.record(sink, signal, timestamp, data)
      {sink, clock_now}
    end)
  end
end
