defmodule Sonda.Sink.Null do
  defstruct []

  @type t :: %__MODULE__{}

  @spec configure() :: t()
  def configure do
    %__MODULE__{}
  end

  defimpl Sonda.Sink do
    def record(%module{} = sink, _signal, _timestamp, _data) do
      module.record(sink)
    end
  end

  @spec record(sink :: t()) :: t()
  def record(sink) do
    sink
  end
end
