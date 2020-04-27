defmodule Sonda.Agent.Default.ChildSpecTest do
  use ExUnit.Case, async: true

  describe "Input is configuration options" do
    test "Agent started" do
      agent =
        start_supervised!({
          Sonda.Agent.Default,
          sinks: [Sonda.Sink.Null.configure()]
        })

      assert Process.alive?(agent)
    end
  end

  describe "Input is configuration options with clock" do
    test "Agent started" do
      agent =
        start_supervised!({
          Sonda.Agent.Default,
          sinks: [Sonda.Sink.Null.configure()],
          clock_now: &NaiveDateTime.utc_now/0
        })

      assert Process.alive?(agent)
    end
  end
end
