defmodule Server.Riak do

  def buckets() do
    {:ok, {{'HTTP/1.1', code, msg}, _headers, body}} = :httpc.request(:get, {"http://localhost:8098/buckets?buckets=true", []},[], [])
    {code, msg, body}
  end

  def keys(bucket) do
    url = "http://localhost:8098/buckets/" <> bucket <> "/keys?keys=true"
    {:ok, {{'HTTP/1.1', code, msg}, _headers, body}} = :httpc.request(:get, {url, []}, [], [])
    {code, msg, body}
  end

  def get_obj(bucket, key) do
    url = "http://localhost:8098/buckets/" <> bucket <> "/keys/" <> key
    {:ok, {{'HTTP/1.1', code, msg}, headers, body}} = :httpc.request(:get, {url, []},[], [])
    case code do
      x when x <= 300 ->
        [{'content-type', type}] =
          headers
            |>  Enum.filter(fn h ->
                  elem(h, 0) === 'content-type'
                end)

        {:ok, code, {body, type}}
      _ ->
        {:error, code, msg}
    end
  end

  def put_obj(bucket, obj, type) do
    url = "http://localhost:8098/buckets/" <> bucket <> "/keys"
    {:ok, {{'HTTP/1.1', code, msg}, headers, _body}} = :httpc.request(:post, {url, [], to_charlist(type), obj}, [], [])
    case code do
      x when x <= 300 ->
        [{'location', loc}] =
          headers
            |>  Enum.filter(fn h ->
                  elem(h, 0) === 'location'
                end)

        [_, key] = String.split(to_string(loc), "keys/")
        {:ok, code, key}
      _ ->
        {:error, code, msg}
    end
  end

  def put_obj(bucket, obj, type, key) do
    url = "http://localhost:8098/buckets/" <> bucket <> "/keys/" <> key
    {:ok, {{'HTTP/1.1', code, msg}, _headers, _body}} = :httpc.request(:put, {url, [], to_charlist(type), obj}, [], [])
    case code do
      x when x < 300 ->
        {:ok, code, msg}
      _ ->
        {:error, code, msg}
    end
  end

  def del_obj(bucket, key) do
    url = "http://localhost:8098/buckets/" <> bucket <> "/keys/" <> key
    {:ok, {{'HTTP/1.1', code, msg}, _headers, _body}} = :httpc.request(:delete, {url, []},[], [])
    {code, msg}
  end

  def upload_schema(schemaName, xmlFilePath) do
    url = "http://localhost:8098/search/schema/" <> schemaName
    case File.read(xmlFilePath) do
      {:ok, data} ->
        {:ok, {{'HTTP/1.1', code, msg}, _headers, body}} = :httpc.request(:put, {url, [], 'application/xml', data}, [], [])
        {code, msg, body}

      {:error, reason} ->
        IO.inspect(reason)
        reason
    end

  end

  def create_index(indexName, schemaName) do
    url= "http://localhost:8098/search/index/" <> indexName
    {:ok, {{'HTTP/1.1', code, msg}, _headers, body}} = :httpc.request(:put, {url, [], 'application/json', Poison.encode!(%{"schema" => schemaName})}, [], [])
    {code, msg, body}
  end

  def assign_index(bucket, index) do
    url= "http://localhost:8098/buckets/" <> bucket <> "/props"
    props = Poison.encode!(%{"props" => %{"search_index" => index}})
    {:ok, {{'HTTP/1.1', code, msg}, _headers, body}} = :httpc.request(:put, {url, [], 'application/json', props}, [], [])
    {code, msg, body}
  end

  def update_bucket(bucket) do
    {_ , _, key_obj} = keys(bucket)
    %{"keys" => keys} = Poison.decode!(to_string(key_obj))
    keys
      |>
        Enum.map(fn key ->
          {_, _, {val, type}} = get_obj(bucket, key)
          put_obj(bucket, val, type, key)
        end)
    :ok
  end

  def del_bucket(bucket) do
    {_ , _, key_obj} = keys(bucket)
    %{"keys" => keys} = Poison.decode!(to_string(key_obj))
    keys |>
      Enum.map(fn key ->
        del_obj(bucket, key)
      end)
    :ok
  end

  def search(index, query, page \\ 0, rows \\ 30, sort \\ "creation_date_index") do
    url  = ~s[http://localhost:8098/search/query/#{index}/?wt=json&q=#{query}&start=#{rows * page}&rows=#{rows}&sort=#{sort}%20desc]
    {:ok, {{'HTTP/1.1', _code, _msg}, _headers, body}} = :httpc.request(:get, {url, []}, [], [])
    %{"docs" => docs, "numFound" => numFound} = Poison.decode!(body)["response"]
    if rem(numFound, rows) == 0 do
      %{"docs" => docs, "numFound" => div(numFound, rows)}
    else
      %{"docs" => docs, "numFound" =>  div(numFound, rows) + 1}
    end
  end
end
