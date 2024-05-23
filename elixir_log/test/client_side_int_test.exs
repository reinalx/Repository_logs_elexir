defmodule ClientSideIntegrationTest do
  use ExUnit.Case

  ## ENCENDER EL REPOSITORIO EN UNA TERMINAL iex --sname server@localhost -S mix
  setup_all do
    {:ok, _pid} = SyslogReader.start_link("user1")
    File.write("support_files/logs.txt", valid_log(), [:append])
    :ok
  end

  test "Verificamos que esta suscrito" do
    assert ["user1"] = Repository.send_user_list()
  end

  test "enviar mensaje y verificar que llego al repositorio" do
    Process.sleep(1000)
    [resp | _] = Repository.send_logs(1, ["user1"])
    assert "user1" = resp.user
    assert 1 = length(resp.logs)
  end

  test "parseo correcto de un log bien formateado" do
    Process.sleep(1000)

    [resp | _] = Repository.send_logs(1, ["user1"])
    assert resp.logs |> Enum.any?(fn log -> log["log"] == "log message." end)
    assert resp.logs |> Enum.any?(fn log -> log["service"] == "service" end)
  end

  defp valid_log() do
    {_, {act_hour, act_min, _}} = :calendar.local_time()
    min = act_min |> Integer.to_string() |> String.pad_leading(2, "0")
    hour = act_hour |> Integer.to_string() |> String.pad_leading(2, "0")
    "Month dd #{hour}:#{min}:00 user1 service: log message."
  end
end
