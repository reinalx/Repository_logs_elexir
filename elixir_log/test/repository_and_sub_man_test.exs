defmodule RepositoryAndSubManTest do
  use ExUnit.Case

  setup do
    {:ok, _} = Repository.start_link()
    {:ok, _pid} = SubscriptionManager.start_link()
    Process.sleep(500)
    {:ok, _} = SyslogReader.start_link("user1")
    {:ok, _} = SyslogReader.start_link("user2")
    Process.sleep(500)
    valid_log_write()
    :ok
  end

  @tag timeout: :infinity
  test "cliente se puede suscribir y recibir mensajes" do

    :ok = SubscriptionManager.subscribe(["user1"], self())


    assert_receive {:response, [response|_]}, 70_000
    assert  %{user: "user1", logs: logs } = response
    assert 1 == length(logs)

  end

  @tag timeout: :infinity
  test "suscripcion a usuario que no existe en el repositorio" do

    :ok = SubscriptionManager.subscribe(["unexistence_user"], self())
    assert_receive {:response, []}, 70_000

  end

  @tag timeout: :infinity
  test "cambiar de suscripcion y recibir mensajes" do
    :ok = SubscriptionManager.subscribe(["user1"], self())

    assert_receive {:response, [response|_]}, 70_000
    assert  %{user: "user1", logs: logs } = response
    assert 1 == length(logs)

    :ok = SubscriptionManager.subscribe(["user2"], self())

    assert_receive {:response, [response|_]}, 70_000
    assert  %{user: "user2", logs: logs } = response
    assert 1 == length(logs)

  end

  test "obtener lista de usuarios del repositorio" do

    assert ["user2", "user1"] = SubscriptionManager.send_users()
  end

  defp valid_log_write() do
    {_, {act_hour, act_min, _}} = :calendar.local_time()
    min = act_min |> Integer.to_string() |> String.pad_leading(2, "0")
    hour = act_hour |> Integer.to_string() |> String.pad_leading(2, "0")
    log = "Month dd #{hour}:#{min}:00 user1 service: log message.\n"
    File.write("support_files/logs.txt", log, [:append])
  end
end
