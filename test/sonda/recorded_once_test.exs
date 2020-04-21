defmodule Sonda.RecordedOnceTest do
  use ExUnit.Case, async: true

  describe "No recording" do
    test "False" do
      pid = start_supervised!(Sonda)

      recorded? = Sonda.recorded_once?(pid, &match?({:a_signal, _, _}, &1))

      refute recorded?
    end
  end

  describe "One recording" do
    test "True" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal)
      recorded? = Sonda.recorded_once?(pid, &match?({:a_signal, _, _}, &1))

      assert recorded?
    end
  end

  describe "Two same recording" do
    test "False" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal)
      Sonda.record(pid, :a_signal)
      recorded? = Sonda.recorded_once?(pid, &match?({:a_signal, _, _}, &1))

      refute recorded?
    end
  end
end
