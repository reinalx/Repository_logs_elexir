defmodule DataBaseTest do
  alias ElixirLS.LanguageServer.Providers.ExecuteCommand.GetExUnitTestsInFile
  use ExUnit.Case

  describe "retrieve_db/0" do
    test "base de datos con ficheros" do
      {:ok, _} = File.copy("support_files/test_db.json", "data_base/test_db.json")
      assert [{"test_db", _log_map} | _tail] = DataBase.retrieve_db()
      :ok = File.rm("data_base/test_db.json")
    end

    test "base de datos vacia" do
      assert [] = DataBase.retrieve_db()
    end
  end
end
