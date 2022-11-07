defmodule JsonLoader do

  def load_orders(bucket, json_file) do
    case File.read(json_file) do
      {:ok, data} ->
        parsed_data = data
          |> Poison.Parser.parse!(%{})
        parsed_data |> Stream.chunk_every(div(length(parsed_data), 10)) |> Enum.map(fn block -> Task.async( fn -> load_orders_block(bucket, block) end) end)
        :ok

      {:error, reason} ->
        IO.puts ~s(#{inspect reason})
        :error
    end
  end

  def load_orders_block(bucket, block) do
    block
    |>
      Enum.map(fn order_data ->
        %{"id" => order_id} = order_data
        Server.Riak.put_obj(bucket, Poison.encode!(order_data), "application/json", order_id)
      end)
  end
end
