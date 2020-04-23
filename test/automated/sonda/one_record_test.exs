defmodule Sonda.OneRecordTest do
  use ExUnit.Case, async: true

  describe "Recorded once" do
    test "Record is found" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal)
      result = Sonda.one_record(pid, &match?({:a_signal, _, _}, &1))

      assert match?({:ok, {:a_signal, _, _}}, result)
    end
  end

  describe "Two different signals recorded" do
    test "Record is found" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal)
      Sonda.record(pid, :other_signal)
      result = Sonda.one_record(pid, &match?({:a_signal, _, _}, &1))

      assert match?({:ok, {:a_signal, _, _}}, result)
    end
  end

  describe "Same signal recorded twice" do
    test "Error" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal)
      Sonda.record(pid, :a_signal)
      result = Sonda.one_record(pid, &match?({:a_signal, _, _}, &1))

      assert match?({:error, :multiple}, result)
    end
  end

  describe "No signal recorded" do
    test "Error" do
      pid = start_supervised!(Sonda)

      result = Sonda.one_record(pid, &match?({:a_signal, _, _}, &1))

      assert match?({:error, :none}, result)
    end
  end
end
