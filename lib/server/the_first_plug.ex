defmodule TheFirstPlug do
  import Plug.Conn

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    case conn.request_path do
      "/" ->
        conn
          |> put_resp_content_type("text/plain")
          |> send_resp(200, "Welcome to the new world of Plugs!")
      "/me" ->
        conn
          |> put_resp_content_type("text/plain")
          |> send_resp(200, "I am The First, The One, Le Geant Plug Vert, Le Grand Plug, Le Plug Cosmique.")
      _ ->
        conn
          |> put_resp_content_type("text/plain")
          |> send_resp(404, "Go away, you are not welcome here.")
    end
  end

end
