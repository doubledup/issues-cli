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
end
