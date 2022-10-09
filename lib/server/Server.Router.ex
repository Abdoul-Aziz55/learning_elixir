defmodule Server.Router do
  use Plug.Router
  import Plug.Conn

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
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Valeur supprimée avec succès")
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Erreur 404")
  end

end
