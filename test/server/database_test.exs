defmodule Server.DatabaseTest do
  use ExUnit.Case

  setup context do
    _ = start_supervised!({Server.Database, name: context.test})
    Server.Database.create(context.test, "AzSolo", 1)
    %{database: context.test}
  end

  # behind the scenes verifies that a value is correctly inserted
  # in the database
  test "reads a value in database", %{database: database} do
    assert Server.Database.read(database, "AzSolo") == {:ok, 1}
  end

  test "updates a value in database", %{database: database} do
    Server.Database.update(database, "AzSolo", 3)

    assert Server.Database.read(database, "AzSolo") == {:ok, 3}
  end

  test "deletes a value in database", %{database: database} do
    Server.Database.delete(database, "AzSolo")

    assert Server.Database.read(database, "AzSolo") == :error
  end

  test "searches a value in database", %{database: database} do
    Server.Database.create(database, "toto" ,%{"id" => "toto", "key" => 42})
    Server.Database.create(database, "test" ,%{"id" => "test", "key" => "42"})
    Server.Database.create(database, "tata" ,%{"id" => "tata", "key" => "Apero?"})
    Server.Database.create(database, "kbrw" ,%{"id" => "kbrw", "key" => "Oh yeah"})

    {:ok, orders1} = Server.Database.search(database, [{"key", "42"}])
    {:ok, orders2} = Server.Database.search(database, [{"key", "42"}, {"key", 42}])
    {:ok, orders3} = Server.Database.search(database, [{"id", "52"}, {"id", "ThisIsATest"}])

    assert orders1 == [%{"id" => "test", "key" => "42"}]
    assert orders2 == [%{"id" => "test", "key" => "42"}, %{"id" => "toto", "key" => 42}]
    assert orders3 == []
  end
end
