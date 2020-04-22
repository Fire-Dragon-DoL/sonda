defprotocol Sonda.Sink do
  @type t :: any()
  @spec record(
          sink :: t(),
          signal :: Sonda.signal(),
          timestamp :: NaiveDateTime.t(),
          data :: any()
        ) :: t()
  def record(sink, signal, timestamp, data)
end
