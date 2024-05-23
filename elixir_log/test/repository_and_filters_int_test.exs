defmodule RepositoryFiltersIntegrationTest do
  use ExUnit.Case
  @qty 5
  setup do
    {:ok, _} = Repository.start_link()
    {:ok, _} = Filters.start_link()
    Process.sleep(500)
    {:ok, _} = SyslogReader.start_link("user1")
    {:ok, _} = SyslogReader.start_link("user2")
    Process.sleep(500)
    Enum.each(1..@qty, fn _ -> valid_log_write() end)
    valid_log_write("keyword")
    valid_log_write("", "alt_service")
    Process.sleep(500)
  end

  test "Filtrar por usuario y  ultimo minuto" do
    [resp | _] = Filters.send_logs(1, ["user1"])
    assert @qty + 2 == length(resp.logs)
    assert "user1" = resp.user
  end

  test "Filtrar por todos los logs del repositorio" do
    resp = Filters.send_all_logs()
    assert 2 = length(resp)

    assert true =
             Enum.all?(
               resp,
               fn %{user: user, logs: log} ->
                 user == "user1" or
                   (user == "user2" and
                      length(log) == @qty + 2)
               end
             )
  end

  test "filtrar por keyword" do
    keyword = "keyword"
    Process.sleep(500)
    Filters.send_logs(1, ["user1"])
    Process.sleep(500)
    [%{logs: logs, user: user} | _] = Filters.filter_keywords(keyword)
    [log | _] = logs
    log_message = log["log"]
    assert "user1" = user
    assert String.contains?(log_message, keyword)
  end

  test "filtrar por service" do
    service = "alt_service"
    Process.sleep(500)
    Filters.send_logs(1, ["user1"])
    Process.sleep(500)
    [%{logs: logs, user: user} | _] = Filters.filter_service(service)
    [log | _] = logs
    assert "user1" = user
    assert "alt_service" = log["service"]
  end

  test "redo filtrado" do
    service = "alt_service"
    Process.sleep(500)
    logs = Filters.send_logs(1, ["user1"])
    Process.sleep(500)
    logs_diff = Filters.filter_service(service)
    Process.sleep(500)
    assert logs != logs_diff
    assert logs == Filters.filter_redo()
  end

  defp valid_log_write(add_word \\ "", service \\ "service") do
    {_, {act_hour, act_min, _}} = :calendar.local_time()
    min = act_min |> Integer.to_string() |> String.pad_leading(2, "0")
    hour = act_hour |> Integer.to_string() |> String.pad_leading(2, "0")
    log = "Month dd #{hour}:#{min}:00 user1 #{service}: log message #{add_word}.\n"
    File.write("support_files/logs.txt", log, [:append])
  end
end
