defprotocol Sonda.Sink do
  @type t :: any()
  @type signal :: atom()

  @spec record(
          sink :: t(),
          signal :: signal(),
          timestamp :: NaiveDateTime.t(),
          data :: any()
        ) :: t()
  def record(sink, signal, timestamp, data)
end
