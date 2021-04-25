defmodule Metex.Worker do
  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})

      _ ->
        IO.puts("Unknown message")
    end

    loop()
  end

  defp temperature_of(location) do
    case url_for(location) |> HTTPoison.get() |> parse_response do
      {:ok, res} -> "#{location}: #{res}"
      :error -> "#{location} not found"
    end
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
