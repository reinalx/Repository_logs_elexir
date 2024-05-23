defmodule Filters do
  @moduledoc """
  Módulo encargado de filtrar y procesar registros de logs.

  Este módulo proporciona funciones para filtrar registros de logs por diversos criterios
  como tiempo, usuarios, palabras clave y servicio.
  """
  use GenServer

  # ------------------------------------------API----------------------------------------------#
  @doc """
  Inicia el módulo `Filters`.
  """
  @spec start_link(opts :: Keyword.t()) :: {:ok, pid} | {:error, any()}
  def start_link(_ \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Envía logs filtrados por tiempo y usuarios especificados.
  """
  @spec send_logs(minutes :: pos_integer(), users :: list(String.t())) :: any()
  def send_logs(minutes, users)
      when is_integer(minutes) and minutes > 0 and is_list(users) and length(users) > 0 do
    GenServer.call({__MODULE__, :server@localhost}, {:send_logs, minutes, users})
  end

  @doc """
  Envía todos los logs sin filtrar.
  """
  def send_all_logs() do
    GenServer.call({__MODULE__, :server@localhost}, :send_all_logs)
  end

  @doc """
  Filtra logs por palabras clave especificadas.

  ## Ejemplo

    iex> Filters.filter_keywords("error warning")
    {:ok, filtered_logs}
  """
  @spec filter_keywords({keywords :: String.t()}) :: any()
  def filter_keywords(keywords) when is_binary(keywords) do
    GenServer.call({__MODULE__, :server@localhost}, {:keywords, keywords})
  end

  @doc """
  Filtra logs por un servicio especificado.

  ## Ejemplo

      iex> Filters.filter_service("System")
      {:ok, filtered_logs}
  """
  @spec filter_service({service :: String.t()}) :: any()
  def filter_service(service) when is_binary(service) do
    GenServer.call({__MODULE__, :server@localhost}, {:service, service})
  end

  @doc """
  Repite el último filtro aplicado.
  """
  def filter_redo do
    GenServer.call({__MODULE__, :server@localhost}, :redo)
  end

  # --------------------------------------------------------------------------------------------#
  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:send_logs, minutes, users}, {pid, _}, state) do
    logs_list = GenServer.call(Repository, {:send_logs, minutes, users})
    {:reply, logs_list, Map.put(state, pid, [logs_list])}
  end

  @impl true
  def handle_call(:send_all_logs, {pid, _}, state) do
    logs_list = GenServer.call(Repository, :send_all_logs)
    {:reply, logs_list, Map.put(state, pid, [logs_list])}
  end

  @impl true
  def handle_call({:keywords, keywords}, {pid, _}, state) do
    [last_log | _] = state[pid]
    logs_list = keywords_filter(last_log, keywords)
    {:reply, logs_list, Map.put(state, pid, [logs_list | state[pid]])}
  end

  @impl true
  def handle_call({:service, service}, {pid, _}, state) do
    [last_log | _] = state[pid]
    logs_list = service_filter(last_log, service)
    {:reply, logs_list, Map.put(state, pid, [logs_list | state[pid]])}
  end

  @impl true
  def handle_call(:redo, {pid, _}, state) do
    previous_logs =
      if tl(state[pid]) == [] do
        state[pid]
      else
        tl(state[pid])
      end

    {:reply, hd(previous_logs), Map.put(state, pid, previous_logs)}
  end

  defp keywords_filter(logs_list, keywords) do
    logs_list
    |> Enum.map(fn %{user: user, logs: logs} ->
      %{
        user: user,
        logs:
          logs
          |> Enum.filter(fn log_props ->
            log_props["log"] =~ keywords
          end)
      }
    end)
  end

  defp service_filter(logs_list, service) do
    logs_list
    |> Enum.map(fn %{user: user, logs: logs} ->
      %{
        user: user,
        logs:
          logs
          |> Enum.filter(fn log_props ->
            log_props["service"] == service
          end)
      }
    end)
  end
end
