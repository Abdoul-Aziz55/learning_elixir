defmodule Server.TheCreator do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import Plug.Conn
      import Server.TheCreator


      # Initialize some macros
      @get_requests []
      @error_request %{code: 404, content: "Go away, you are not welcome here"}

      # Invoke TestCase.__before_compile__/1 before the module is compiled
      @before_compile Server.TheCreator
    end
  end

  defmacro my_error(code: code, content: content) do
    function_name = String.to_atom("my_error")
    quote do
      @error_request Map.put(@error_request, :code, unquote(code))
      @error_request Map.put(@error_request, :content, unquote(content))
      def unquote(function_name)(), do: {unquote(code), unquote(content)}
    end
  end

  defmacro my_get(description, do: block) do
    func_name = String.to_atom(description)
    quote do
      @get_requests [unquote(func_name) | @get_requests]
      def unquote(func_name)(), do: unquote(block)
    end
  end



  # This will be invoked right before the target module is compiled
  # giving us the perfect opportunity to inject the `run/0` function
  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def init(opts) do
        opts
      end

      def call(conn, _opts) do
        the_request =
          Enum.map(
            @get_requests,
            fn name ->
              content = apply(__MODULE__, name, [])

              {Atom.to_string(name), content}
            end
          )
          |>
            Enum.filter(
              fn {request_path, content} ->
                request_path == conn.request_path
              end
            )

          case the_request do
            [{_, {code, response}}] -> send_resp(conn, code, response)
                  []                -> send_resp(conn, @error_request.code, @error_request.content)
          end
      end
    end
  end

end
