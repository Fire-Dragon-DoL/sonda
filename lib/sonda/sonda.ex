defmodule Sonda do
  defstruct sinks: [Sonda.MemorySink.configure()]

  @type signal :: atom()
  @type t :: %__MODULE__{
          sinks: [Sonda.Sink.t()]
        }
  @type config_opts :: [
          {:sinks, [Sonda.Sink.t()]} | {:clock_now, (() -> NaiveDateTime.t())}
        ]

  @spec configure() :: t()
  def configure()

  @spec configure(opts :: config_opts()) :: t()
  def configure(opts \\ []) do
    struct(__MODULE__, opts)
  end

  @spec start_link(
          config_opts :: config_opts(),
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link(config_opts \\ [], opts \\ []) do
    clock_now = Keyword.get(config_opts, :clock_now, &NaiveDateTime.utc_now/0)
    config_opts = Keyword.delete(config_opts, :clock_now)
    sonda = configure(config_opts)
    Sonda.Agent.start_link({sonda, clock_now}, opts)
  end

  @spec record(
          sonda :: t(),
          signal :: signal(),
          timestamp :: NaiveDateTime.t(),
          data :: any()
        ) :: t()
  def record(sonda, signal, timestamp, data) do
    sinks = sonda.sinks
    sinks = Enum.map(sinks, &Sonda.Sink.record(&1, signal, timestamp, data))
    %{sonda | sinks: sinks}
  end
end
