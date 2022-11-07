defmodule Server.Router do
  use Plug.Router
  import Plug.Conn

  plug Plug.Static, from: "priv/static", at: "/static"
  plug :match
  plug :dispatch

  get "/create" do
    params = fetch_query_params(conn).query_params
    %{"id" => id} = params
    Server.Database.create(Server.Database, id, params)
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Valeur ajoutée avec succès")
  end

  get "/update" do
    params = fetch_query_params(conn).query_params
    %{"id" => id} = params
    Server.Database.update(Server.Database, id, params)
    conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Valeur mise à jour avec succès")
  end

  get "/delete" do
    params = fetch_query_params(conn).query_params
    %{"id" => id} = params
    Server.Database.delete(Server.Database, id)
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(202, Poison.encode!(%{"ok"=> "ok"}))
  end

  get "/orders" do
    params = fetch_query_params(conn).query_params
    riak_params =
      Stream.filter(["rows", "page", "sort"], fn param -> Map.has_key?(params, param) end)
      |>
      Enum.reduce(%{"rows" => "30", "page" => "0", "sort" => "creation_date_index"}, fn param, acc ->
        %{^param => val} = params
        Map.put(acc, param, val)
      end)
    IO.inspect params
    IO.inspect riak_params

    if params === %{} do
      res = Server.Riak.search("order", "*:*")
      conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(res))
    else

      qs = params
      |> Enum.filter(fn {k, _} -> !Enum.member?(["rows", "page", "sort"], k) end)
      |> Enum.reduce("", fn {field, val}, acc ->
          if acc === "" do
            acc <> "#{field}:#{val}"
          else
            acc <> "%20AND%20#{field}:#{val}"
          end
        end)

      res =
        case qs do
          "" -> Server.Riak.search("order", "*:*", elem(Integer.parse(riak_params["page"]), 0), elem(Integer.parse(riak_params["rows"]), 0), riak_params["sort"])
          _ -> Server.Riak.search("order", qs, elem(Integer.parse(riak_params["page"]), 0), elem(Integer.parse(riak_params["rows"]), 0), riak_params["sort"])
        end

      conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, Poison.encode!(res))
    end

  end

  get _ do
    path = fetch_query_params(conn).request_path
    case String.match?(path, ~r(order\/)) do
      true ->
        order_id = Enum.at(String.split(path, "order/"), 1)
        res = Server.Riak.search("order", "id:#{order_id}")
          conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Poison.encode!(res))

      _ -> send_file(conn, 200, "priv/static/index.html")
    end

  end

end
