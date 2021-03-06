defmodule Sonda.Agent.ChildSpecTest do
  use ExUnit.Case, async: true

  describe "Input is configuration options" do
    test "Agent started" do
      agent =
        start_supervised!({
          Sonda.Agent,
          {Sonda.Sink.Null.configure(), &NaiveDateTime.utc_now/0}
        })

      assert Process.alive?(agent)
    end
  end

  describe "Input is only sink" do
    test "Agent started" do
      agent = start_supervised!({Sonda.Agent, Sonda.Sink.Null.configure()})

      assert Process.alive?(agent)
    end
  end

  describe "Input is configuration options and keyword name option" do
    test "Agent started with name" do
      name = :"with_name_#{__MODULE__}"

      agent =
        start_supervised!({
          Sonda.Agent,
          {
            {Sonda.Sink.Null.configure(), &NaiveDateTime.utc_now/0},
            [name: name]
          }
        })

      agent_from_name = Process.whereis(name)

      assert agent_from_name == agent
    end
  end

  describe "Input is sink and keyword name option" do
    test "Agent started with name" do
      name = :"with_other_name_#{__MODULE__}"

      agent =
        start_supervised!({
          Sonda.Agent,
          {
            Sonda.Sink.Null.configure(),
            [name: name]
          }
        })

      agent_from_name = Process.whereis(name)

      assert agent_from_name == agent
    end
  end
end
