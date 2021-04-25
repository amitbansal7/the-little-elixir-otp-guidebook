defmodule Metex do
  def temperature_of(cities) do
    coordinator_id = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

    cities
    |> Enum.each(fn city ->
      worker_id = spawn(Metex.Worker, :loop, [])
      send(worker_id, {coordinator_id, city})
    end)
  end
end
