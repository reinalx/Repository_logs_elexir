defmodule Repository do
  @moduledoc """
  Modulo que implementa el repositorio de logs. Guarda los ultimos 60 minutos de logs.

  Este módulo proporciona funcionalidades para conectar usuarios, insertar logs,
  y recuperar logs en formatos crudos o procesados. Está diseñado para trabajar
  con una base de datos simulada usando ficheros en formato Json
  """
  use GenServer

  @template_file "support_files/template.json"

  # ----------------API----------------------------------------------#
  @doc """
  Inicializa el Repositorio
  """
  @spec start_link() :: {:ok, pid} | {:error, tuple}
  def start_link(), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Establece una nueva conexión para un usuario.

  Si el usuario ya está conectado, simplemente retorna `:ok`.
  En caso contrario, añade el usuario al estado con un template de logs vacío.

  ## Parametros
  - user: el nombre de usuario a conectar.
  """
  @spec new_connection(user :: String.t()) :: :ok | :already_connected
  def new_connection(user) do
    GenServer.call({__MODULE__, :server@localhost}, {:new_connection, user})
  end

  @doc """
  Solicita todos los logs almacenados en su formato original.
  """
  @spec send_all_logs_raw() :: {:ok, term()}
  def send_all_logs_raw() do
    GenServer.call(__MODULE__, :send_all_logs_raw)
  end

  @doc """
  Envía los ultimos x minutos de logs para usuarios específicos.

  ## Parametros

  - minutes: número de minutos hacia atrás desde el momento actual para recuperar logs.
  - users: lista de usuarios cuyos logs se quieren recuperar.

  ## Ejemplo

      iex> Repository.send_logs(15, ["usuario1", "usuario2"])
      [%{user: "usuario1", logs: [] }, %{user: "usuario2", logs: []}]
  """
  @spec send_logs(minutes :: pos_integer(), users :: nonempty_list(String.t())) ::
          term() | {:error, Exception.t()}
  def send_logs(minutes, users)
      when is_integer(minutes) and minutes > 0 and is_list(users) and length(users) > 0 do
    GenServer.call({__MODULE__, :server@localhost}, {:send_logs, minutes, users})
  end

  @doc """
  Recupera todos los logs de todos los usuarios para el último intervalo de 60 minutos.

  Esta función procesa los logs almacenados y los devuelve en un formato estructurado.

  ## Ejemplo

      iex> Repository.send_all_logs()
      [%{user: "usuario1", logs: []}, %{user: "usuario2", logs: []]}]
  """
  @spec send_all_logs() :: list() | {:error, Exception.t()}
  def send_all_logs() do
    GenServer.call({__MODULE__, :server@localhost}, :send_all_logs)
  end

  @doc """
  Inserta logs para un usuario específico.

  Los logs deben ser proporcionados como una lista de mapas que contienen las claves
  `:hour`, `:minute` y `:log`.
  y el mapa :log tiene que ser con el siguiente formato:
    %{"date_time" => String.t(), "service" => String.t(), "log" => String.t()}

  ## Parameters

  - user: el nombre de usuario para el cual se insertarán los logs.
  - logs: lista de mapas con la estructura `%{hour: pos_integer(), minute: String.t(), log: map()}`.

  """
  @spec insert_logs(
          user :: String.t(),
          logs :: list(%{:hour => pos_integer(), :minute => String.t(), :log => map()})
        ) :: :ok | {:error, Exception.t()}
  def insert_logs(user, logs) when is_binary(user) and is_list(logs) do
    GenServer.cast({__MODULE__, :server@localhost}, {:insert_logs, %{user: user, logs: logs}})
  end

  @doc """
  Recupera una lista de strings de los usuarios que envian logs al repositorio
  """
  @spec send_user_list() :: list(String.t())
  def send_user_list() do
    GenServer.call({__MODULE__, :server@localhost}, :users_list)
  end

  # ------------------------------------------------------------------#
  @impl true
  def init(:ok) do
    db = DataBase.retrieve_db()
    {:ok, db}
  end

  @impl true
  def handle_call({:new_connection, user}, _from, state) do
    if check_user_whitelist(user) do
      if List.keyfind(state, user, 0) do
        {:reply, :already_connected, state}
      else
        {:reply, :ok, [{user, template_to_map()} | state]}
      end
    else
      {:reply, {:error, "#{user} is not authorized to send logs"}, state}
    end
  end

  @impl true
  def handle_call(:send_all_logs_raw, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:send_logs, minutes, users}, _from, state) do
    minute_list = minutes_list(minutes)

    response =
      List.foldl(users, [], fn user, acc ->
        case List.keyfind(state, user, 0) do
          nil ->
            # No se encontraron logs para ese usuario
            acc

          {_, user_logs_map} ->
            logs = user_logs_map |> log_map_to_list(minute_list)
            [%{user: user, logs: logs} | acc]
        end
      end)

    {:reply, response, state}
  end

  @impl true
  def handle_call(:send_all_logs, _from, state) do
    minute_list = minutes_list(60)

    response =
      List.foldl(state, [], fn {user, logs}, acc ->
        logs_formated = logs |> log_map_to_list(minute_list)
        [%{user: user, logs: logs_formated} | acc]
      end)

    {:reply, response, state}
  end

  @impl true
  def handle_call(:users_list, _from, state) do
    response = Enum.map(state, fn {user, _map} -> user end)
    {:reply, response, state}
  end

  @impl true
  def handle_cast({:insert_logs, %{user: user, logs: logs}}, state) do
    case List.keyfind(state, user, 0) do
      nil ->
        {:noreply, state}

      {_, user_logs} ->
        new_user_logs = List.foldl(logs, user_logs, fn log, acc -> insert_log_db(acc, log) end)
        {:noreply, List.keyreplace(state, user, 0, {user, new_user_logs})}
    end
  end

  @impl true
  def handle_cast(:print, state) do
    IO.inspect(state)
    {:noreply, state}
  end

  @impl true
  def terminate(:normal, _state) do
    DataBase.delete_db()
    GenServer.stop(DataBase)
    :normal
  end

  @impl true
  def terminate(reason, _state) do
    GenServer.stop(DataBase)
    reason
  end

  defp template_to_map() do
    {:ok, file} = File.open(@template_file, [:read])
    {:ok, json} = IO.read(file, :eof) |> JSON.decode()
    :ok = File.close(file)
    json
  end

  defp insert_log_db(map, %{hour: hour, minute: minute, log: log}) do
    %{"hour" => old_hour, "logs" => old_logs} = Map.get(map, minute)

    if old_hour == hour do
      Map.replace(map, minute, %{"hour" => old_hour, "logs" => [log | old_logs]})
    else
      Map.replace(map, minute, %{"hour" => hour, "logs" => [log]})
    end
  end

  defp log_map_to_list(map, min_list) do
    {_, {act_hour, act_min, _}} = :calendar.local_time()

    List.foldl(min_list, [], fn min, acc ->
      %{"hour" => log_hour, "logs" => logs} = Map.get(map, min)

      if valid_logs?(log_hour, min, act_hour, act_min) do
        acc ++ logs
      else
        acc
      end
    end)
    |> Enum.reverse()
  end

  defp valid_logs?(log_hour, log_min, act_hour, act_min) do
    # para cuando sean las 00
    act_hour_mod = positive_mod(act_hour - 1, 24)

    log_hour != nil &&
      ((log_min > act_min && log_hour == act_hour_mod) ||
         log_hour == act_hour)
  end

  defp minutes_list(interval) do
    {_date, {_hour, minute, _sec}} = :calendar.local_time()

    Enum.map((minute - interval + 1)..minute, fn x ->
      x
      |> positive_mod(60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")
    end)
    |> Enum.reverse()
  end

  defp positive_mod(n, divisor) do
    rem = rem(n, divisor)

    if rem < 0 do
      rem + divisor
    else
      rem
    end
  end

  defp check_user_whitelist(user) do
    {:ok, string} = File.read("support_files/whitelist")
    users_list = string |> String.split("\n")
    users_list |> Enum.any?(fn user_wl -> user == user_wl end)
  end
end
