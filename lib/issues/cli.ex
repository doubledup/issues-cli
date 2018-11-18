defmodule Issues.CLI do
  import Issues.TableFormatter, only: [format_for_columns: 2]

  @default_count 4

  @module_doc """
  Handle command line parsing and dispatching to functions that generate a
  table of the last _n_ issues in a Github project
  """

  def main(argv) do
    argv
    |> parse_args()
    |> process()
    |> IO.puts()
  end

  @doc """
  [-h | --help] | [github_user_name, github_project_name[, number_of_entries]]

  If `argv` contains -h or --help, returns :help.

  If `argv` contains 2 or 3 strings that aren't switches, these should be a
  github username, project name and an optional number of entries to format.

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

  def process(:help) do
    IO.puts("""
    usage: issues <user> <project> [count | #{@default_count}]
    """)

    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order()
    |> Enum.take(count)
    |> format_for_columns(["number", "created_at", "title", "html_url"])
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error[:reason]}")
    System.halt(2)
  end

  def sort_into_descending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(&(&1["created_at"] >= &2["created_at"]))
  end
end
