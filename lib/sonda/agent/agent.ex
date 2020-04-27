defmodule Sonda.Agent do
  use Agent

  @type t :: Agent.agent()
  @type clock :: (() -> Sonda.Sink.timestamp())
  @type config :: {Sonda.Sink.t(), clock()}
  @type config_opts :: config() | Sonda.Sink.t()

  @spec configure(sink :: Sonda.Sink.t()) :: config()
  def configure(sink) do
    {sink, &NaiveDateTime.utc_now/0}
  end

  @spec start_link(config_opts :: config_opts()) :: Agent.on_start()
  def start_link(config_opts), do: start_link(config_opts, [])

  @spec start_link(
          config_opts :: config_opts(),
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link(config_opts, opts)

  def start_link({sink, clock_now}, opts) do
    Agent.start_link(fn -> {sink, clock_now} end, opts)
  end

  def start_link(sink, opts) do
    start_link({sink, &NaiveDateTime.utc_now/0}, opts)
  end

  @spec child_spec(spec_opts :: config_opts() | {config_opts(), keyword()}) ::
          Supervisor.child_spec()
  def child_spec(spec_opts)

  def child_spec({config_opts, opts})
      when is_list(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [config_opts, opts]}
    }
  end

  def child_spec({_sink, clock_now} = config) when is_function(clock_now) do
    child_spec({config, []})
  end

  def child_spec(sink) do
    child_spec({sink, []})
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
