defmodule Sonda.Sink.Memory do
  defmodule Defaults do
    def signals, do: :any
  end

  defstruct signals: Defaults.signals(), records: []

  @type record :: {Sonda.Sink.signal(), NaiveDateTime.t(), any()}
  @type accepted_signals :: :any | [Sonda.Sink.signal()]
  @type config_opts :: [
          {:signals, accepted_signals()}
        ]
  @type matcher :: (record() -> boolean())
  @type t :: %__MODULE__{
          signals: accepted_signals(),
          records: [record()]
        }

  defimpl Sonda.Sink do
    def record(%module{} = sink, signal, timestamp, data) do
      module.record(sink, signal, timestamp, data)
    end
  end

  @spec configure() :: t()
  def configure()

  @spec configure(opts :: config_opts()) :: t()
  def configure(opts \\ []) do
    struct(__MODULE__, opts)
  end

  @spec record(
          sink :: t(),
          signal :: Sonda.Sink.signal(),
          timestamp :: NaiveDateTime.t(),
          data :: any()
        ) :: t()
  def record(sink, signal, timestamp, data) do
    case record_signal?(sink, signal) do
      false ->
        sink

      true ->
        records = sink.records
        new_record = {signal, timestamp, data}
        records = [new_record | records]
        %{sink | records: records}
    end
  end

  @spec recorded?(sink :: t(), match :: matcher()) :: boolean()
  def recorded?(sink, match) do
    Enum.find_value(sink.records, false, fn record ->
      match.(record)
    end)
  end

  @spec records(sink :: t()) :: [record()]
  def records(sink) do
    Enum.reverse(sink.records)
  end

  @spec records(sink :: t(), match :: matcher()) :: [record()]
  def records(sink, match) do
    sink.records
    |> Enum.filter(match)
    |> Enum.reverse()
  end

  @spec record_signal?(sink :: t(), signal :: Sonda.Sink.signal()) :: boolean()
  def record_signal?(sink, signal)
  def record_signal?(%{signals: :any}, _signal), do: true
  def record_signal?(%{signals: signals}, signal), do: signal in signals

  @spec one_record(sink :: t(), match :: matcher()) ::
          {:ok, record()} | {:error, :none} | {:error, :multiple}
  def one_record(sink, match) do
    records = records(sink, match)

    case records do
      [] -> {:error, :none}
      [record] -> {:ok, record}
      _ -> {:error, :multiple}
    end
  end

  @spec recorded_once?(sink :: t(), match :: matcher()) :: boolean()
  def recorded_once?(sink, match) do
    case one_record(sink, match) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
