defmodule CLITest do
  use ExUnit.Case
  doctest Issues.CLI

  test "with no arguments, -h or --help, return :help" do
    assert Issues.CLI.parse_args([]) == :help
    assert Issues.CLI.parse_args(["-h", "anything"]) == :help
    assert Issues.CLI.parse_args(["-help", "anything"]) == :help
  end

  test "with two strings, use the default count value" do
    assert Issues.CLI.parse_args(["uname", "projname"]) == {"uname", "projname", 4}
  end

  test "with three strings, return their parsed values" do
    assert Issues.CLI.parse_args(["uname", "projname", "42"]) == {"uname", "projname", 42}
  end

  test "sort_descending orders the correct way" do
    result = Issues.CLI.sort_into_descending_order(fake_created_at_list(["c", "a", "b"]))
    created_at_values = Enum.map(result, &(Map.get(&1, "created_at")))
    assert created_at_values == ~w{c b a}
  end

  defp fake_created_at_list(values) do
    Enum.map(values, &(%{"created_at" => &1, "other_data" => 42}))
  end
end
