defmodule Sonda do
  @type signal :: atom()
  @type config_opts :: [
          {:sinks, [Sonda.Sink.t()]} | {:clock_now, (() -> NaiveDateTime.t())}
        ]

  @spec start_link(
          config_opts :: config_opts(),
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link(config_opts \\ [], opts \\ []) do
    clock_now = Keyword.get(config_opts, :clock_now, &NaiveDateTime.utc_now/0)
    config_opts = Keyword.delete(config_opts, :clock_now)
    sink = Sonda.Sink.Multi.configure(config_opts)
    Sonda.Agent.start_link({sink, clock_now}, opts)
  end
end
