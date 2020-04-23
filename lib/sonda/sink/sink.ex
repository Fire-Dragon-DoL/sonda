defprotocol Sonda.Sink do
  @type t :: any()
  @type signal :: atom()
  @type timestamp :: NaiveDateTime.t() | any()

  @spec record(
          sink :: t(),
          signal :: signal(),
          timestamp :: timestamp(),
          data :: any()
        ) :: t()
  def record(sink, signal, timestamp, data)
end
