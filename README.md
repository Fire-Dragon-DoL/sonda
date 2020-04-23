# Sonda

Sonda is a telemetry library for Elixir, providing configurable sinks for
recording signals.

By default, Sonda is configured to record signals in memory and can be
inspected through the provided utility functions.

```elixir
{:ok, pid} = Sonda.start_link()
Sonda.record(pid, :a_signal, %{"some" -> "data"})
Sonda.recorded_once?(pid, &match?({:a_signal, _, _}, &1)) # => true
Sonda.record(pid, :another_signal, 123)
Sonda.record(pid, :signal_only)
Sonda.records(pid)
# [
#    {:a_signal, ~N[2020-04-22 23:07:05.905776], %{"some" -> "data"}},
#    {:another_signal, ~N[2020-04-22 23:07:06.905776], 123}},
#    {:signal_only, ~N[2020-04-22 23:07:07.905776], nil}
# ]
```

## Installation

The package can be installed by adding `sonda` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:sonda, "~> 0.1.0"}
  ]
end
```

Docs can be found at [https://hexdocs.pm/sonda](https://hexdocs.pm/sonda).

## Basic Usage

The default configuration of Sonda provides all the utility functions for
recording signals in memory and then inspecting the output:

### Start

```elixir
{:ok, pid} = Sonda.start_link()
```

### Record signals

```elixir
Sonda.record(pid, :a_signal, %{"some" -> "data"})
Sonda.record(pid, :another_signal, 123)
Sonda.record(pid, :signal_only)
```

### Inspect

#### Was any message ever recorded with this shape?

```elixir
Sonda.recorded?(pid, &match?({:a_signal, _, _}, &1)) # => true
```

#### Was any message ever recorded with this shape **only one time**?

```elixir
Sonda.recorded_once?(pid, &match?({:a_signal, _, _}, &1)) # => true
```

#### List all the recorded messages starting from the oldest

```elixir
Sonda.records(pid)
# [
#    {:a_signal, ~N[2020-04-22 23:07:05.905776], %{"some" -> "data"}},
#    {:another_signal, ~N[2020-04-22 23:07:06.905776], 123}},
#    {:signal_only, ~N[2020-04-22 23:07:07.905776], nil}
# ]
```

#### List all the recorded messages starting from the oldest and matching the provided function

```elixir
Sonda.records(pid, fn {_, _, data} -> data != 123 end)
# [
#    {:a_signal, ~N[2020-04-22 23:07:05.905776], %{"some" -> "data"}},
#    {:signal_only, ~N[2020-04-22 23:07:07.905776], nil}
# ]
```

#### Gets the first recorded message matching the provided function, only if there is only one. An error is returned in all the other cases

```elixir
Sonda.one_record(pid, fn {_, _, data} -> data == 123 end)
# {:ok, {:another_signal, ~N[2020-04-22 23:07:06.905776], 123}}}
```

#### Gets the first recorded message matching the provided function, only if there is only one. An error is returned in all the other cases

```elixir
Sonda.one_record(pid, fn {_, _, data} -> data == 123 end)
# {:ok, {:another_signal, ~N[2020-04-22 23:07:06.905776], 123}}}
```

#### Is this signal allowed to be recorded?

```elixir
Sonda.record_signal?(pid, :a_signal) # => true
```

See the [Filtering Signals](#filtering-signals) section for more information
about why a signal might be recorded or not. This output of this function
is `false` for any signal that's not accepted.

### Filtering Signals

It's possible to ignore some signals from being recorded. It's sufficient to
start Sonda with the following configuration:

```elixir
{:ok, pid} = Sonda.start_link(signals: [:a_signal, :another_signal])
```

The output of the function `Sonda.record_signal?/2` is `true` only for the
signals `:a_signal` and `:another_signal`, like in the following example:

```elixir
{:ok, pid} = Sonda.start_link(signals: [:a_signal, :another_signal])

Sonda.record_signal?(pid, :a_signal) # => true
Sonda.record_signal?(pid, :another_signal) # => true
Sonda.record_signal?(pid, :not_recorded) # => false
```

When the input of the functions `record/2` and `record/3` is a signal for
which the output of `Sonda.record_signal?/2` is `false`,
**no operation is performed**. The following example shows that `:not_recorded`
signal is ignored:

```elixir
{:ok, pid} = Sonda.start_link(signals: [:a_signal, :another_signal])

Sonda.record(pid, :a_signal, %{"some" -> "data"})
Sonda.record(pid, :not_recorded)
Sonda.record(pid, :another_signal, 123)

Sonda.records(pid)
# [
#    {:a_signal, ~N[2020-04-22 23:07:05.905776], %{"some" -> "data"}},
#    {:another_signal, ~N[2020-04-22 23:07:06.905776], 123}}
# ]
```

## Common Usage

### ExUnit

One of the most common purpose of Sonda is to inspect the usage of closures or
the behavior of GenServers. The following example shows the closure being
invoked twice by inspecting the signals recorded through Sonda:

```elixir
defmodule SomeTest do
  use ExUnit.Case

  test "Enum.map/2 is invoked once per list element" do
    sonda = start_supervised!(Sonda)
    elements = [1, 2]

    elements = Enum.map(elements, fn element ->
      Sonda.record(sonda, :map, element)
      element * 2
    end)
    records = Sonda.records(sonda)

    assert elements == [2, 4]
    assert length(records) == 2
  end
end
```

## Advanced Usage

TODO:
- Multiple sinks
- Custom sinks
- Custom clock

## Thanks

This library is heavily influenced by
[telemetry](https://github.com/eventide-project/telemetry), the
[Eventide](https://eventide-project.org/) library for ruby instrumentation.
