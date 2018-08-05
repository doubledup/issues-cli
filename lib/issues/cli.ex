defmodule Issues.CLI do
  @default_count 4

  @module_doc """
  Handle command line parsing and dispatching to functions that generate a
  table of the last _n_ issues in a Github project
  """

  def run(argv) do
    parse_args(argv)
  end

  @doc """
  [-h | --help] | [github_user_name, github_project_name[, number_of_entries]]

  If `argv` contains -h or --help, returns :help.

  If `argv` contains 2 or 3 non-switch strings, these should be a github
  username, project name and an optional number of entries to format.

  Otherwise this returns :help
  """
  def parse_args(argv) do
    OptionParser.parse(
      argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end
end
