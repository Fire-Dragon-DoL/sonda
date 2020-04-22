defmodule Sonda.Agent do
  use Agent

  @spec start_link(
          config :: {Sonda.t(), (() -> NaiveDateTime.t())},
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link({sonda, clock_now}, opts) do
    Agent.start_link(fn -> {sonda, clock_now} end, opts)
  end

  @spec record(
          server :: Agent.agent(),
          signal :: Sonda.signal(),
          data :: any()
        ) ::
          :ok
  def record(server, signal, data) do
    Agent.update(server, fn {sonda, clock_now} ->
      timestamp = clock_now.()
      sonda = Sonda.record(sonda, signal, timestamp, data)
      {sonda, clock_now}
    end)
  end
end
