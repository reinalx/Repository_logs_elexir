defmodule RepositoryTest do
  use ExUnit.Case

  ## EL DIRECTORIO data_base DEBE ESTAR VACIO

  describe "start_link/0" do
    test "Inicia el reposirorio exitosamente" do
      assert {:ok, _pid} = Repository.start_link()
    end
  end

  describe "new_connection/1" do
    setup do
      {:ok, _pid} = Repository.start_link()
      :ok
    end

    test "conexión de usuario exitosa" do
      assert :ok = Repository.new_connection("user1")
    end

    test "returns :already_connected para un usuario ya conectado" do
      Repository.new_connection("user1")
      assert :already_connected = Repository.new_connection("user1")
    end
  end

  describe "insert_logs/2" do
    setup do
      {:ok, _pid} = Repository.start_link()
      Repository.new_connection("user1")
    end

    test "inserta logs correctamente" do
      logs = [
        %{
          hour: 14,
          minute: "30",
          log: %{"date_time" => "14:30", "service" => "web", "log" => "log message"}
        }
      ]

      assert :ok = Repository.insert_logs("user1", logs)
    end
  end

  describe "send_all_logs_raw/0" do
    setup do
      {:ok, _pid} = Repository.start_link()
      :ok = Repository.new_connection("user1")

      logs = [
        %{
          hour: 14,
          minute: "30",
          log: %{"date_time" => "14:30", "service" => "web", "log" => "log message"}
        }
      ]

      Repository.insert_logs("user1", logs)
    end

    test "recuperar todos los logs en formato crudo" do
      assert [{"user1", _map}] = Repository.send_all_logs_raw()
    end
  end

  describe "send_logs/2" do
    setup do
      {:ok, _pid} = Repository.start_link()
      :ok = Repository.new_connection("user1")
      {_, {act_hour, act_min, _}} = :calendar.local_time()

      logs = [
        %{
          hour: act_hour,
          minute: act_min |> Integer.to_string(),
          log: %{"date_time" => "hh:mm", "service" => "web", "log" => "log message"}
        }
      ]

      Repository.insert_logs("user1", logs)
    end

    test "envia logs del ultimo minuto de un usuario especifico" do
      assert [%{user: "user1", logs: _}] = Repository.send_logs(1, ["user1"])
    end

    test "envia logs de un usuario que no existe" do
      assert [] = Repository.send_logs(1, ["non_existence"])
    end
  end

  describe "send_all_logs/0" do
    setup do
      {:ok, _pid} = Repository.start_link()
      :ok = Repository.new_connection("user1")
      :ok = Repository.new_connection("user2")
      {_, {act_hour, act_min, _}} = :calendar.local_time()

      logs = [
        %{
          hour: act_hour,
          minute: act_min |> Integer.to_string(),
          log: %{"date_time" => "hh:mm", "service" => "web", "log" => "log message"}
        }
      ]

      Repository.insert_logs("user1", logs)
    end

    test "recupera todos los logs de todos los usuarios" do
      assert [%{user: "user1", logs: _}, %{user: "user2", logs: _}] = Repository.send_all_logs()
    end
  end

  describe "send_user_list" do
    setup do
      {:ok, _pid} = Repository.start_link()
      :ok = Repository.new_connection("user1")
      :ok = Repository.new_connection("user2")
    end

    test "recupera todos los usuarios conectados al repositorio" do
      assert ["user2", "user1"] = Repository.send_user_list()
    end
  end
end
