defmodule Sonda do
  alias Sonda.Agent.Default

  defdelegate child_spec(opts), to: Default
  defdelegate start_link(), to: Default
  defdelegate start_link(config_opts), to: Default
  defdelegate start_link(config_opts, opts), to: Default
  defdelegate record(server, signal, data \\ nil), to: Default
  defdelegate recorded?(server, match), to: Default
  defdelegate records(server), to: Default
  defdelegate records(server, match), to: Default
  defdelegate record_signal?(server, signal), to: Default
  defdelegate one_record(server, match), to: Default
  defdelegate recorded_once?(server, match), to: Default
end
