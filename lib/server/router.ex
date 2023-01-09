defmodule Server.Router do
  require EEx
  use Plug.Router
  import Plug.Conn

  plug Plug.Static, at: "/public", from: :learning_elixir
  EEx.function_from_file :defp, :layout, "web/layout.html.eex", [:render]

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
    {code, msg} = Server.Riak.del_obj("orders", id)
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(code, Poison.encode!(msg))
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

    if params === %{} do
      %{"code" => code, "docs" => docs , "numFound" => numFound } = Server.Riak.search("order", "*:*")
      res = %{"docs" => docs , "numFound" => numFound}
      IO.inspect(res)
      conn
        |> put_resp_content_type("application/json")
        |> send_resp(code, Poison.encode!(res))
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

      %{"code" => code, "docs" => docs , "numFound" => numFound } =
        case qs do
          "" -> Server.Riak.search("order", "*:*", elem(Integer.parse(riak_params["page"]), 0), elem(Integer.parse(riak_params["rows"]), 0), riak_params["sort"])
          _ -> Server.Riak.search("order", qs, elem(Integer.parse(riak_params["page"]), 0), elem(Integer.parse(riak_params["rows"]), 0), riak_params["sort"])
        end
      res = %{"docs" => docs , "numFound" => numFound}
      IO.inspect(res)
      conn
        |> put_resp_content_type("text/plain")
        |> send_resp(code, Poison.encode!(res))
    end

  end

  get "/order/:order_id" do
    res = Server.Riak.search("order", "id:#{order_id}")
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(res))

  end

  get _ do
    conn = fetch_query_params(conn)
    render = Reaxt.render!(:app, %{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000)
    send_resp(put_resp_header(conn,"content-type","text/html;charset=utf-8"), render.param || 200,layout(render))
  end

end
