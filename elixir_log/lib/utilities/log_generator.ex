defmodule LogGenerator do
  @moduledoc """
  Módulo encargado de generar registros de logs y escribirlos en un archivo.

  Este módulo se utiliza para generar registros de logs simulados para diferentes servicios
  y escribirlos en un archivo de registro especificado.
  """
  use GenServer

  @log_path "support_files/logs.txt"
  @services ["httpd", "sshd", "nginx", "apache", "mysql"]
  @log_interval 1000 * 5
  @month_map %{
    1 => "Jan",
    2 => "Feb",
    3 => "Mar",
    4 => "Apr",
    5 => "May",
    6 => "Jun",
    7 => "Jul",
    8 => "Aug",
    9 => "Sep",
    10 => "Oct",
    11 => "Nov",
    12 => "Dec"
  }

  @doc """
  Inicia el módulo `LogGenerator`.
  """
  @spec start_link() :: {:ok, pid} | {:error, any()}
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    generate_log_entry()
    {:ok, []}
  end

  @impl true
  @doc """
  Maneja la recepción de mensajes para generar registros de logs.
  """
  @spec handle_info(atom(), any()) :: {:noreply, any()}
  def handle_info(:generate_log, state) do
    generate_log_entry()
    {:noreply, state}
  end

  @impl true
  @doc """
  Limpia recursos antes de la terminación del proceso.
  """
  @spec terminate(any(), any()) :: any()
  def terminate(_reason, _state) do
    File.rm(@log_path)
  end

  @doc """
  Genera un registro de log y lo escribe en el archivo de registro especificado.
  """
  @spec generate_log_entry() :: String.t()
  def generate_log_entry do
    {{_year, month, day}, {hour, minute, second}} = :calendar.local_time()

    month_name = Map.get(@month_map, month)
    day_str = String.pad_leading(Integer.to_string(day), 2, "0")
    hour_str = String.pad_leading(Integer.to_string(hour), 2, "0")
    minute_str = String.pad_leading(Integer.to_string(minute), 2, "0")
    second_str = String.pad_leading(Integer.to_string(second), 2, "0")

    timestamp = "#{month_name} #{day_str} #{hour_str}:#{minute_str}:#{second_str}"

    {:ok, hostname} = :inet.gethostname()
    service = Enum.random(@services)
    message = generate_random_message()

    log_entry = "#{timestamp} #{hostname} #{service}: #{message}"

    File.write!(@log_path, log_entry <> "\n", [:append])

    Process.send_after(self(), :generate_log, @log_interval)

    log_entry
  end

  defp generate_random_message do
    random_messages = [
      "Operation completed successfully.",
      "An error occurred.",
      "Service is starting.",
      "Service is stopping.",
      "Connection established."
    ]

    Enum.random(random_messages)
  end
end
