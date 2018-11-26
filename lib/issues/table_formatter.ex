defmodule Issues.TableFormatter do
  @doc """
  Format issues with headings.

  iex> Issues.TableFormatter.format_for_columns(
  ...>  [[title: "no_tests", body: "need more assertions"], [title: "debugger_is_cool", body: "`break!` is fun!"]],
  ...>  [:title, :body])
  "title            | body                \n-----------------+---------------------\nno_tests         | need more assertions\ndebugger_is_cool | `break!` is fun!    "
  """
  def format_for_columns(list_of_issues, headings) do
    column_widths =
      for heading <- headings do
        max_length_of_field(list_of_issues, heading)
      end

    heading = render_row(headings, column_widths)

    separator =
      column_widths
      |> Enum.map(&String.duplicate("-", &1))
      |> Enum.join("-+-")

    rows =
      list_of_issues
      |> extract_issue_data(headings)
      |> Enum.map(&(render_row(&1, column_widths)))
      |> Enum.join("\n")

    Enum.join([heading, separator, rows], "\n")
  end

  defp max_length_of_field(list_of_maps, field) do
    list_of_maps
    |> Enum.map(
      &(&1[field]
        |> Kernel.to_string
        |> String.length)
    )
    |> Enum.max
    |> Kernel.max(field |> to_string |> String.length)
  end

  defp render_row(fields, column_widths) do
    Enum.zip(fields, column_widths)
    |> Enum.map(fn {field, width} ->
      field
      |> Kernel.to_string
      |> String.pad_trailing(width)
    end)
    |> Enum.join(" | ")
  end

  defp extract_issue_data(maps, headings) do
    for map <- maps do
      for heading <- headings do
        map[heading]
      end
    end
  end
end
