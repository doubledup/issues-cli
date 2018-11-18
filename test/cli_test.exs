defmodule CLITest do
  use ExUnit.Case
  doctest Issues.CLI

  import Issues.CLI, only: [parse_args: 1, sort_into_descending_order: 1]

  test "with no arguments, -h or --help, return :help" do
    assert parse_args([]) == :help
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["-help", "anything"]) == :help
  end

  test "with two strings, use the default count value" do
    assert parse_args(["uname", "projname"]) == {"uname", "projname", 4}
  end

  test "with three strings, return their parsed values" do
    assert parse_args(["uname", "projname", "42"]) == {"uname", "projname", 42}
  end

  test "sort_descending orders the correct way" do
    result =
      ["c", "a", "b"]
      |> fake_created_at_list
      |> sort_into_descending_order
      |> Enum.map(&Map.get(&1, "created_at"))

    assert result == ~w{c b a}
  end

  defp fake_created_at_list(values) do
    Enum.map(values, &%{"created_at" => &1, "other_data" => 42})
  end
end
