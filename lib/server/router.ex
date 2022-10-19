defmodule Server.Router do
  use Plug.Router
  import Plug.Conn

  plug Plug.Static, from: "priv/static", at: "/static"
  plug :match
  plug :dispatch


  get "/search" do
    criterias = Map.to_list(fetch_query_params(conn).query_params)
    {:ok, result} = Server.Database.search(Server.Database, criterias)
    case result do
      [] ->
        conn
          |> put_resp_content_type("text/plain")
          |> send_resp(200, "Aucun résultat trouvé")
      result ->
        conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(result))
    end


  end

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
    {:ok, orders} = Server.Database.get_all(Server.Database)
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(orders))
  end

  get _ do
    path = fetch_query_params(conn).request_path
    case String.match?(path, ~r(order\/)) do
      true ->
        order_id = Enum.at(String.split(path, "order/"), 1)
        case Server.Database.read(Server.Database, order_id) do
          {:ok, order} ->
            conn
              |> put_resp_content_type("application/json")
              |> send_resp(200, Poison.encode!(order))

          _ -> send_resp(conn, 404, "valeur introuvable")
          end
      _ -> send_file(conn, 200, "priv/static/index.html")
    end

  end



  # match _ do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(404, "Erreur 404")
  # end

end
