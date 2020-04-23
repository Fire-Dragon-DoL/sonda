defmodule Sonda.RecordTest do
  use ExUnit.Case, async: true

  test "Data is recorded" do
    pid = start_supervised!(Sonda)

    Sonda.record(pid, :a_signal, 123)
    recorded? = Sonda.recorded?(pid, &match?({_, _, 123}, &1))

    assert recorded?
  end

  @now ~N[1970-01-01 00:00:00.000000]

  test "Timestamp is recorded" do
    pid = start_supervised!({Sonda, clock_now: fn -> @now end})

    Sonda.record(pid, :a_signal, nil)
    recorded? = Sonda.recorded?(pid, &match?({_, @now, _}, &1))

    assert recorded?
  end

  describe "Any signal accepted" do
    test "Signal recorded" do
      pid = start_supervised!(Sonda)

      Sonda.record(pid, :a_signal, nil)
      recorded? = Sonda.recorded?(pid, &match?({:a_signal, _, _}, &1))

      assert recorded?
    end
  end

  describe "List of signals accepted" do
    test "Accepted signal is recorded" do
      pid = start_supervised!({Sonda, signals: [:accepted]})

      Sonda.record(pid, :accepted, nil)
      recorded? = Sonda.recorded?(pid, &match?({:accepted, _, _}, &1))

      assert recorded?
    end

    test "Unknown signal ignored" do
      pid = start_supervised!({Sonda, signals: [:accepted]})

      Sonda.record(pid, :unknown, nil)
      recorded? = Sonda.recorded?(pid, &match?({:unknown, _, _}, &1))

      refute recorded?
    end
  end
end
