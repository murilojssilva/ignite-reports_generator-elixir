defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @options [
    "foods",
    "users"
  ]

  @available_foods [
    "açaí",
    "churrasco",
    "esfirra",
    "hambúrguer",
    "pastel",
    "pizza",
    "prato_feito",
    "sushi"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  def fetch_higher_cost({:ok, report}, option) when option in @options do
    {:ok, Enum.max_by(report[option], fn {_key, value} -> value end)}
  end

  def fetch_higher_cost({_, _report}, _option), do: {:error, "Invalid option!"}

  defp sum_values([id, food_name, price], %{"foods" => foods, "users" => users}) do
    users = Map.put(users, id, nil_to_zero(users[id]) + price)
    foods = Map.put(foods, food_name, nil_to_zero(foods[food_name]) + 1)

    # report
    # |> Map.put("users", users)
    # |> Map.put("foods", foods)

    build_report(foods, users)
  end

  defp nil_to_zero(value) do
    # this function allows a dynamic list with new foods without the need to update the list
    # not updating it would break the function
    case value do
      nil -> 0
      _ -> value
    end
  end

  defp report_acc do
    build_report(%{}, %{})
  end

  defp build_report(foods, users), do: %{"foods" => foods, "users" => users}
end
