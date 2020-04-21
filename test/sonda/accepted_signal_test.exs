defmodule Sonda.AcceptedSignalTest do
  use ExUnit.Case, async: true

  describe "Signals set to :any" do
    test "True for any signal" do
      accepted? = Sonda.accepted_signal?(:any, :a_signal)

      assert accepted?
    end
  end

  @accepted_signals [:a_signal, :another_signal]

  describe "Signals set to list" do
    test "True for signal in list" do
      accepted? = Sonda.accepted_signal?(@accepted_signals, :a_signal)

      assert accepted?
    end

    test "False for signal not present in list" do
      accepted? = Sonda.accepted_signal?(@accepted_signals, :unknown)

      refute accepted?
    end
  end
end
