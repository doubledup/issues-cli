defmodule Issues.CLI do
  @default_count 4

  @module_doc """
  Handle command line parsing and dispatching to functions that generate a
  table of the last _n_ issues in a Github project
  """

  def run(argv) do
    argv
    |> parse_args()
    |> process()
    |> format()
    |> IO.puts()
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

  def format(list_of_issues) do
    heading = [
      Enum.join(
        [
          String.pad_trailing("#", max_length_of_field(list_of_issues, "number")),
          String.pad_trailing("created_at", max_length_of_field(list_of_issues, "created_at")),
          String.pad_trailing("title", max_length_of_field(list_of_issues, "title"))
        ],
        " | "
      ),
      Enum.join(
        [
          String.duplicate("-", max_length_of_field(list_of_issues, "number")),
          String.duplicate("-", max_length_of_field(list_of_issues, "created_at")),
          String.duplicate("-", max_length_of_field(list_of_issues, "title"))
        ],
        "-+-"
      )
    ]

    list_of_issues
    |> Enum.map(&"#{&1["number"]} | #{&1["created_at"]} | #{&1["title"]}")
    |> (&(heading ++ &1)).()
    |> Enum.join("\n")
  end

  defp max_length_of_field(map, field) do
    map
    |> Enum.map(
      &(&1[field]
        |> Kernel.to_string()
        |> String.length())
    )
    |> Enum.max()
  end
end
