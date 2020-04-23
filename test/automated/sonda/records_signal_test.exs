defmodule Sonda.RecordSignalTest do
  use ExUnit.Case, async: true

  describe "Signals set to :any" do
    test "True for any signal" do
      pid = start_supervised!(Sonda)

      record_signal? = Sonda.record_signal?(pid, :a_signal)

      assert record_signal?
    end
  end

  @accepted_signals [:a_signal, :other_signal]

  describe "Signals set to list" do
    test "True for signal in list" do
      pid = start_supervised!({Sonda, signals: @accepted_signals})

      record_signal? = Sonda.record_signal?(pid, :a_signal)

      assert record_signal?
    end

    test "False for signal not present in list" do
      pid = start_supervised!({Sonda, signals: @accepted_signals})

      record_signal? = Sonda.record_signal?(pid, :unknown)

      refute record_signal?
    end
  end
end
