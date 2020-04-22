defmodule Sonda.Agent do
  use Agent

  @type t :: Agent.agent()

  @spec start_link(config :: {Sonda.Sink.t(), (() -> NaiveDateTime.t())}) ::
          Agent.on_start()
  def start_link(config), do: start_link(config, [])

  @spec start_link(
          config :: {Sonda.Sink.t(), (() -> NaiveDateTime.t())},
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link({sink, clock_now}, opts) do
    Agent.start_link(fn -> {sink, clock_now} end, opts)
  end

  @spec record(
          server :: t(),
          signal :: Sonda.Sink.signal(),
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

  @spec get_sink(
          server :: t(),
          (Sonda.Sink.t() -> any())
        ) :: any()
  def get_sink(server, fun) do
    Agent.get(server, fn {sink, _} ->
      fun.(sink)
    end)
  end
end
