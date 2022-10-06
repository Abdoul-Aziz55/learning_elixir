defmodule JsonLoader do

  def load_to_database(database, json_file) do
    case File.read(json_file) do
      {:ok, data} ->
        data
          |> Poison.Parser.parse!(%{})
          |> Enum.map(fn order_data ->
            %{"id" => order_id} = order_data
            Server.Database.update(database, order_id, order_data)
          end)
          :ok

      {:error, reason} ->
        IO.puts ~s(#{inspect reason})
        :error
    end
  end
end
