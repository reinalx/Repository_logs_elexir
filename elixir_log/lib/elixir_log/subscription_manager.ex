defmodule SubscriptionManager do
  @moduledoc """
  Modulo que implementa el manejo de suscripciones.

  Este modulo sirve para gestionar las suscripciones por parte de
  clientes a determinados usuarios que envian logs.
  """
  use GenServer
  @poll_time 60 * 1000 * 1 ##COMENTAR PARA TESTEAR
  #@poll_time 10 * 1000 * 1 ##USAR PARA TEST repository_and_sub_man_test
  
  # ----------------API----------------------------------------------#
  @doc """
  Inicializa el modulo
  """
  @spec start_link() :: {:ok, pid} | {:error, tuple}
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Un cliente se suscribe a una lista de usuarios.

  Parametros:
  - user_list: Lista de usuarios a los que el cliente se suscribe.
  - pid: Proceso del cliente que se suscribe.
  """
  @spec subscribe(users :: list(String.t()), pid) :: :ok
  def subscribe(user_list, pid) do
    IO.inspect(pid)
    GenServer.cast({__MODULE__, :server@localhost}, {:subscribe, {pid, user_list}})
  end

  @doc """
  Se realiza una peticion al Repositorio para obtener la lista de usuarios.
  """
  @spec send_users() :: list
  def send_users() do
    GenServer.call({__MODULE__, :server@localhost}, :users_list)
  end

  # ------------------------------------------------------------------#
  @impl true
  def init(_state) do
    Process.send_after(self(), :work, @poll_time)
    {:ok, []}
  end

  @impl true
  def handle_cast({:subscribe, {client, user_list}}, state) do
    pos = Enum.find_index(state, fn {cl, _} -> cl == client end)

    new_state =
      if pos == nil do
        [{client, user_list} | state]
      else
        List.update_at(state, pos, fn _map -> {client, user_list} end)
      end

    IO.inspect({:noreply, new_state})
  end

  @impl true
  def handle_call(:users_list, _, state) do
    users = Repository.send_user_list()
    {:reply, users, state}
  end

  @impl true
  def handle_info(:work, []) do
    Process.send_after(self(), :work, @poll_time)
    {:noreply, []}
  end

  @impl true
  def handle_info(:work, state) do
    users_to_get =
      List.foldl(state, [], fn {_user, user_sub_list}, acc ->
        acc ++ user_sub_list
      end)
      |> Enum.uniq()

    IO.inspect(users_to_get)
    logs = Repository.send_logs(2, users_to_get)
    IO.inspect(logs)
    response(state, logs)
    Process.send_after(self(), :work, @poll_time)
    {:noreply, state}
  end

  def response(state, logs) do
    Enum.each(
      state,
      fn {user, subs} ->
        response = logs_per_subscription(subs, logs)
        IO.inspect(user)
        Process.send(user, {:response, response}, [])
      end
    )
  end

  def logs_per_subscription(subs, logs) do
    List.foldl(subs, [], fn sub, acc ->
      filtered_logs = Enum.filter(logs, fn %{user: user} -> user == sub end)
      filtered_logs ++ acc
    end)
  end
end
