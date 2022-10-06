defmodule JsonLoaderTest do
  use ExUnit.Case

  setup context do
    _ = start_supervised!({Server.Database, name: context.test})
    %{database: context.test}
  end

  test "inserts a json in database", %{database: database} do
    content = ~s([{"name": "AzSolo", "age": 27, "id":1}])
    File.write("./test/test_file.json", content)
    JsonLoader.load_to_database(database, "./test/test_file.json")

    expected = {:ok, %{"name" => "AzSolo", "age" => 27, "id" => 1}}
    assert Server.Database.read(database, 1) == expected
    File.rm("./test/test_file.json")
  end

end
