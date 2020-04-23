defmodule Sonda.Agent.Default do
  @type config_opts :: [
          {:sinks, [Sonda.Sink.t()]} | {:clock_now, (() -> NaiveDateTime.t())}
        ]
  @type t :: {Sonda.Sink.Proxy.t(), (() -> NaiveDateTime.t())}

  @spec configure(opts :: config_opts()) :: t()
  def configure(opts \\ []) do
    clock_now = Keyword.get(opts, :clock_now, &NaiveDateTime.utc_now/0)
    opts = Keyword.delete(opts, :clock_now)

    {sinks, opts} =
      case Keyword.get(opts, :sinks) do
        nil ->
          mem_sink = Sonda.Sink.Memory.configure(opts)
          opts = Keyword.delete(opts, :signals)
          {[mem_sink], opts}

        sinks ->
          opts = Keyword.delete(opts, :sinks)
          {sinks, opts}
      end

    opts = Keyword.put(opts, :sinks, sinks)
    sink = Sonda.Sink.Proxy.configure(opts)
    {sink, clock_now}
  end

  def child_spec(config_opts) do
    config_opts
    |> configure()
    |> Sonda.Agent.child_spec()
  end

  @spec start_link() :: Agent.on_start()
  def start_link(), do: start_link([])

  @spec start_link(config_opts :: config_opts()) :: Agent.on_start()
  def start_link(config_opts), do: start_link(config_opts, [])

  @spec start_link(
          config_opts :: config_opts(),
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link(config_opts, opts) do
    config_opts
    |> configure()
    |> Sonda.Agent.start_link(opts)
  end

  @spec record(server :: Sonda.Agent.t(), signal :: Sonda.Sink.signal()) :: :ok
  def record(server, signal)

  @spec record(
          server :: Sonda.Agent.t(),
          signal :: Sonda.Sink.signal(),
          data :: any()
        ) ::
          :ok
  def record(server, signal, data \\ nil) do
    Sonda.Agent.record(server, signal, data)
  end

  @spec recorded?(
          server :: Sonda.Agent.t(),
          match :: Sonda.Sink.Memory.matcher()
        ) ::
          boolean()
  def recorded?(server, match) do
    get_memory_sink(server, fn mem_sink ->
      Sonda.Sink.Memory.recorded?(mem_sink, match)
    end)
  end

  @spec records(server :: Sonda.Agent.t()) :: [Sonda.Sink.Memory.record()]
  def records(server) do
    get_memory_sink(server, fn mem_sink ->
      Sonda.Sink.Memory.records(mem_sink)
    end)
  end

  @spec records(server :: Sonda.Agent.t(), match :: Sonda.Sink.Memory.matcher()) ::
          [Sonda.Sink.Memory.record()]
  def records(server, match) do
    get_memory_sink(server, fn mem_sink ->
      Sonda.Sink.Memory.records(mem_sink, match)
    end)
  end

  @spec record_signal?(server :: Sonda.Agent.t(), signal :: Sonda.Sink.signal()) ::
          boolean()
  def record_signal?(server, signal) do
    get_memory_sink(server, fn mem_sink ->
      Sonda.Sink.Memory.record_signal?(mem_sink, signal)
    end)
  end

  @spec one_record(
          server :: Sonda.Agent.t(),
          match :: Sonda.Sink.Memory.matcher()
        ) ::
          {:ok, Sonda.Sink.Memory.record()}
          | {:error, :none}
          | {:error, :multiple}
  def one_record(server, match) do
    get_memory_sink(server, fn mem_sink ->
      Sonda.Sink.Memory.one_record(mem_sink, match)
    end)
  end

  @spec recorded_once?(
          server :: Sonda.Agent.t(),
          match :: Sonda.Sink.Memory.matcher()
        ) :: boolean()
  def recorded_once?(server, match) do
    get_memory_sink(server, fn mem_sink ->
      Sonda.Sink.Memory.recorded_once?(mem_sink, match)
    end)
  end

  @spec get_memory_sink(
          server :: Sonda.Agent.t(),
          (Sonda.Sink.Proxy.t() -> any())
        ) :: any()
  def get_memory_sink(server, fun) do
    Sonda.Agent.get_sink(server, fn multi_sink ->
      [mem_sink | _] = multi_sink.sinks
      fun.(mem_sink)
    end)
  end
end
