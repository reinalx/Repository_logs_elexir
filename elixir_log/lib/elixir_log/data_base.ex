defmodule DataBase do
  use GenServer

  @moduledoc """
  Modulo encargado de manejar la BD en disco (ficheros json en un repositorio).
  Cada x minutos solicita al repositorio todos los logs y los guarda en disco.
  Ofrece funciones para leer y escribir la BD en disco.
  """

  @log_directory "data_base"
  @save_logs_time 60 * 10 * 1000

  @doc """
  Inicializa el proceso de solicitud de datos al repositorio.
  """
  @spec start_link() :: {:ok, pid} | {:error, tuple}
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :save_data, @save_logs_time)
    {:ok, nil}
  end

  @impl true
  def handle_info(:save_data, _state) do
    logs = Repository.send_all_logs_raw()
    save_db_on_disk(logs)
    Process.send_after(self(), :save_data, @save_logs_time)
    {:noreply, nil}
  end

  @doc """
   Recupera los datos almacenados desde el disco si existe el repositorio @log_directory,
   si no existe lo crea y devuelve []
  """
  @spec retrieve_db() :: [{String.t(), map()}]
  def retrieve_db() do
    if File.exists?(@log_directory) do
      {:ok, db_files} = File.ls(@log_directory)

      List.foldl(db_files, [], fn name, acc ->
        [user, _extension] = String.split(name, ".")
        [{user, json_file_to_map(name)} | acc]
      end)
    else
      File.mkdir("data_base")
      []
    end
  end

  @doc """
   ELimina recursivamente el directorio donde estan almacenados los logs.
  """
  @spec delete_db() :: {:ok, [binary()]} | {:error, File.posix(), binary()}
  def delete_db() do
    File.rm_rf(@log_directory)
  end

  defp save_db_on_disk(log_list) do
    log_list
    |> Enum.each(fn {user, logs} ->
      map_to_json_file(user, logs)
    end)
  end

  defp json_file_to_map(name) do
    {:ok, file} = File.open(@log_directory <> "/" <> name, [:read])
    {:ok, map} = IO.read(file, :eof) |> JSON.decode()
    :ok = File.close(file)
    map
  end

  defp map_to_json_file(name, map) do
    {:ok, json_str} = map |> JSON.encode()
    :ok = File.write(@log_directory <> "/" <> name <> ".json", json_str)
  end
end
