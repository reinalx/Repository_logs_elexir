defmodule SyslogReader do
  @moduledoc """
  Módulo encargado de leer logs de un archivo de registro y enviarlos al Repositorio.

  Este módulo se utiliza para leer logs de un archivo de registro, formatearlos y enviarlos
  al Repositorio para su almacenamiento y procesamiento posterior.

  Formato correcto de log: 'Mon dd hh:mm:ss localhost service[pid]: log message'
  """
  use GenServer

  @log_file "support_files/logs.txt"
  @poll_interval 1 * 1000
  @hostname :inet.gethostname() |> elem(1) |> to_string()

  @doc """
  Inicia el módulo `SyslogReader`.
  """
  @spec start_link(opts :: Keyword.t()) :: {:ok, pid} | {:error, any()}
  def start_link(name \\ @hostname) do
    GenServer.start_link(__MODULE__, name, name: name |> String.to_atom())
  end

  @impl true
  def init(name) do
    true = Node.connect(:server@localhost)

    case Repository.new_connection(name) do
      :ok ->
        initialize(name)

      :already_connected ->
        keep_conn =
          IO.getn(
            "It seems that you already have an open connection, would you like to continue? y/n: "
          )

        if String.first(keep_conn) == "y" do
          initialize(name)
        else
          :stoping
        end

      {:error, reason} ->
        raise "Error connecting to repository: #{reason}"

      _ ->
        raise "Unexpected response from repository"
    end
  end

  defp initialize(name) do
    {:ok, fp} = File.open(@log_file, [:read])
    :file.position(fp, :eof)
    poll()
    {:ok, {fp, name}}
  end

  @impl true
  @doc """
  Maneja la recepción de mensajes de lectura de líneas de log.
  """
  @spec handle_info(any(), any()) :: {:noreply, any()}
  def handle_info(:read_log_lines, {fp, name}) do
    logs = read_til_eof(fp) |> format_logs
    send_to_channel(name, logs)
    poll()
    {:noreply, {fp, name}}
  end

  defp read_til_eof(fp),
    do: read_til_eof(IO.binread(fp, :line), fp, [])

  defp read_til_eof(:eof, _fp, buffer), do: buffer

  defp read_til_eof(line, fp, buffer),
    do: read_til_eof(IO.binread(fp, :line), fp, buffer ++ [line])

  defp format_logs([]), do: []

  defp format_logs(lines) do
    for line <- lines, do: parse_log(line)
  end

  defp parse_log(line) do
    case String.split(line, " ", parts: 6) do
      [month, day, datetime_str, _hostname, service, log] ->
        [hour, minute, _second] = String.split(datetime_str, ":")
        service = String.replace(service, ":", "")

        %{
          hour: hour |> String.to_integer(),
          minute: minute,
          log: %{
            "date_time" => "#{month} #{day} #{datetime_str}",
            "service" => service,
            "log" => log
          }
        }

      _ ->
        raise RuntimeError,
          message:
            "Invalid log format. Correct format: 'Mon dd hh:mm:ss localhost service[pid]: log message'",
          log: line
    end
  end

  defp send_to_channel(_name, []), do: :ok

  defp send_to_channel(name, logs) do
    Repository.insert_logs(name, logs)
  end

  defp poll(),
    do: Process.send_after(self(), :read_log_lines, @poll_interval)
end
