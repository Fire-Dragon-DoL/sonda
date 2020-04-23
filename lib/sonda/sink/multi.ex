defmodule Sonda.Sink.Multi do
  defstruct sinks: []

  @type t :: %__MODULE__{
          sinks: [Sonda.Sink.t()]
        }
  @type config_opts :: [
          {:sinks, [Sonda.Sink.t()]}
        ]

  @spec configure() :: t()
  def configure()

  @spec configure(opts :: config_opts()) :: t()
  def configure(opts \\ []) do
    struct(__MODULE__, opts)
  end

  defimpl Sonda.Sink do
    def record(%module{} = sink, signal, timestamp, data) do
      module.record(sink, signal, timestamp, data)
    end
  end

  @spec record(
          sink :: t(),
          signal :: Sonda.Sink.signal(),
          timestamp :: NaiveDateTime.t(),
          data :: any()
        ) :: t()
  def record(sonda, signal, timestamp, data) do
    sinks = sonda.sinks
    sinks = Enum.map(sinks, &Sonda.Sink.record(&1, signal, timestamp, data))
    %{sonda | sinks: sinks}
  end
end
