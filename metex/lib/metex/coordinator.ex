require IEx

defmodule Metex.Coordinator do
  def loop(results \\ [], results_expected) do
    receive do
      {:ok, result} ->
        new_res = [result | results]

        if results_expected == Enum.count(new_res) do
          IO.puts(new_res |> Enum.sort() |> Enum.join(", "))
        else
          loop(new_res, results_expected)
        end

      _ ->
        loop(results, results_expected)
    end
  end
end
