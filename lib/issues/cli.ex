defmodule Issues.CLI do
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

  def format_for_columns(list_of_issues, headings) do
    column_widths =
      for heading <- headings do
        max_length_of_field(list_of_issues, heading)
      end

    column_widths =
      column_widths
      |> Enum.zip(headings)
      |> Enum.map(fn {width, heading} -> Kernel.max(width, heading |> String.length()) end)

    IO.inspect(column_widths)

    heading =
      Enum.zip(headings, column_widths)
      |> Enum.map(fn {heading, width} -> String.pad_trailing(heading, width) end)
      |> Enum.join(" | ")

    separator =
      column_widths
      |> Enum.map(&String.duplicate("-", &1))
      |> Enum.join("-+-")

    rows =
      list_of_issues
      |> extract_row_values(headings)
      |> Enum.map(fn row ->
        row
        |> Enum.zip(column_widths)
        |> Enum.map(fn {value, width} ->
          value
          |> Kernel.to_string()
          |> String.pad_trailing(width)
        end)
        |> Enum.join(" | ")
      end)
      |> Enum.join("\n")

    Enum.join([heading, separator, rows], "\n")
  end

  defp extract_row_values(maps, headings) do
    for map <- maps do
      for heading <- headings do
        map[heading]
      end
    end
  end

  defp max_length_of_field(list_of_maps, field) do
    list_of_maps
    |> Enum.map(
      &(&1[field]
        |> Kernel.to_string()
        |> String.length())
    )
    |> Enum.max()
  end
end
