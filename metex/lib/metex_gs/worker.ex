defmodule MetexGs.Worker do
  use GenServer

  @name MW

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: MW])
  end

  def get_temperature(location) do
    GenServer.call(@name, {:location, location})
  end

  def get_stats do
    GenServer.call(@name, :get_stats)
  end

  def reset_stats do
    GenServer.cast(@name, :reset_stats)
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_info(msg, stats) do
    IO.puts("received #{msg}")
    {:noreply, stats}
  end

  def termiate(reason, stats) do
    IO.puts("Server terminated because of #{inspect(reason)}")
    inspect(stats)
    :ok
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temp} ->
        new_stats = update_stats(stats, location)
        {:reply, "#{temp} °C", new_stats}

      _ ->
        {:error, stats}
    end
  end

  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  defp update_stats(old_stats, location) do
    case(Map.has_key?(old_stats, location)) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))

      false ->
        Map.put(old_stats, location, 1)
    end
  end

  defp temperature_of(location) do
    url_for(location) |> HTTPoison.get() |> parse_response
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key()}"
  end

  defp compute_temperature(json) do
    try do
      {
        :ok,
        (json["main"]["temp"] - 273.15) |> Float.round()
      }
    rescue
      _ -> :error
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode!() |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp api_key do
    "001c21fb34d54e291cd82a84fd6f4fb7"
  end
end
