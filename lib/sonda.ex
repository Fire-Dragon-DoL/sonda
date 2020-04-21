defmodule Sonda do
  use Agent

  defstruct signals: :any, records: [], now: &NaiveDateTime.utc_now/0

  @type signal :: atom()
  @type record :: {signal(), NaiveDateTime.t(), any()}
  @type accepted_signals :: :any | [signal()]
  @type config_opts :: [
          {:now, (() -> NaiveDateTime.t())}
          | {:signals, accepted_signals()}
        ]
  @type matcher :: (record() -> boolean())

  @spec configuration(opts :: config_opts()) :: Sonda.t()
  def configuration(opts) do
    struct(__MODULE__, opts)
  end

  @spec start_link(
          config :: config_opts(),
          opts :: keyword()
        ) ::
          Agent.on_start()
  def start_link(config \\ [], opts \\ []) do
    telemetry = configuration(config)
    Agent.start_link(fn -> telemetry end, opts)
  end

  @spec recorded?(
          server :: Agent.agent(),
          match :: (record() -> boolean())
        ) :: boolean()
  def recorded?(server, match) do
    Agent.get(server, fn telemetry ->
      Enum.find_value(telemetry.records, false, fn record ->
        match.(record)
      end)
    end)
  end

  @spec accepted_signal?(signals :: accepted_signals(), signal :: signal()) ::
          boolean()
  def accepted_signal?(signals, signal)

  def accepted_signal?(:any, _signal), do: true
  def accepted_signal?(signals, signal), do: signal in signals

  @spec record(server :: Agent.agent(), signal :: signal(), data :: any()) ::
          :ok
  def record(server, signal, data \\ nil) do
    Agent.update(server, fn telemetry ->
      case accepted_signal?(telemetry.signals, signal) do
        false ->
          telemetry

        true ->
          timestamp = telemetry.now.()
          records = telemetry.records
          new_record = {signal, timestamp, data}
          records = [new_record | records]
          %{telemetry | records: records}
      end
    end)
  end

  @spec records(server :: Agent.agent()) :: [record()]
  def records(server) do
    Agent.get(server, fn telemetry ->
      Enum.reverse(telemetry.records)
    end)
  end

  @spec records(server :: Agent.agent(), match :: matcher()) :: [record()]
  def records(server, match) do
    Agent.get(server, fn telemetry ->
      records =
        Enum.filter(telemetry.records, fn record ->
          match.(record)
        end)

      Enum.reverse(records)
    end)
  end

  @spec record_signal?(server :: Agent.agent(), signal :: signal()) :: boolean()
  def record_signal?(server, signal) do
    Agent.get(server, fn telemetry ->
      accepted_signal?(telemetry.signals, signal)
    end)
  end

  @spec one_record(server :: Agent.agent(), match :: matcher()) ::
          {:ok, record()} | {:error, :none} | {:error, :multiple}
  def one_record(server, match) do
    Agent.get(server, fn telemetry ->
      records =
        Enum.filter(telemetry.records, fn record ->
          match.(record)
        end)

      case records do
        [] -> {:error, :none}
        [record] -> {:ok, record}
        _ -> {:error, :multiple}
      end
    end)
  end

  @spec recorded_once?(server :: Agent.agent(), match :: matcher()) :: boolean()
  def recorded_once?(server, match) do
    case one_record(server, match) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
