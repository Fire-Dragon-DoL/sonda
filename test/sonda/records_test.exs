defmodule Sonda.RecordsTest do
  use ExUnit.Case, async: true

  describe "No matcher" do
    test "List all recorded entries" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal)
      Sonda.record(pid, :another_signal)
      [record1, record2] = Sonda.records(pid)

      assert match?({:a_signal, _, _}, record1)
      assert match?({:another_signal, _, _}, record2)
    end
  end

  describe "Matcher set" do
    test "List matching recorded entries" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal, 1)
      Sonda.record(pid, :another_signal)
      Sonda.record(pid, :a_signal, 2)
      [record1, record2] = Sonda.records(pid, &match?({:a_signal, _, _}, &1))

      assert match?({:a_signal, _, 1}, record1)
      assert match?({:a_signal, _, 2}, record2)
    end
  end
end
