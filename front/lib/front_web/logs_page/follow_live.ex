defmodule FrontWeb.FollowLive do
  alias FrontWeb.LiveLogComponents
  use FrontWeb, :live_view

  import FrontWeb.GetLogs,
    only: [get_users: 0, subscribe_users: 2]

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <section class="grid grid-cols-2 gap-3 divide-x dark:divide-slate-500 divide-gray-900 ">
      <div class="">
        <header class="">
          <h2 class="text-4xl mb-6 me-2 dark:text-white w-auto">Suscribirse a usuarios</h2>
        </header>
        <div>
          <.live_component module={LiveLogComponents} id={12_314_141} users_list={@users} />
        </div>
      </div>
      <div>
        <header class="ml-8 flex flex-wrap items-end space-x-4 ">
          <h2 class="text-4xl mb-6 me-2 dark:text-white">Seguimiento Logs</h2>
        </header>

        <div class="ml-8 min-h-56 ">
          <%= if @user_logs == [] do %>
            <.loading_logs searching={@searching} />
          <% else %>
            <%= for  %{user: user_n, logs: user_l} <- @user_logs do %>
              <.subs_logs user_name={user_n} user_logs={user_l} />
            <% end %>
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  attr :searching, :boolean

  def loading_logs(assigns) do
    ~H"""
    <%= if @searching == true do %>
      <div class="border border-blue-300 shadow rounded-md p-4 mb-4 max-w-sm w-full mx-auto">
        <div class="animate-pulse flex space-x-4">
          <div class="flex-1 space-y-6 py-1">
            <div class="h-2 bg-slate-700 rounded"></div>
            <div class="space-y-3">
              <div class="grid grid-cols-3 gap-4">
                <div class="h-2 bg-slate-700 rounded col-span-2"></div>
                <div class="h-2 bg-slate-700 rounded col-span-1"></div>
              </div>
              <div class="h-2 bg-slate-700 rounded"></div>
            </div>
          </div>
        </div>
      </div>
      <div class="border border-blue-300 shadow rounded-md p-4 mb-4 max-w-sm w-full mx-auto">
        <div class="animate-pulse flex space-x-4">
          <div class="flex-1 space-y-6 py-1">
            <div class="h-2 bg-slate-700 rounded"></div>
            <div class="space-y-3">
              <div class="grid grid-cols-3 gap-4">
                <div class="h-2 bg-slate-700 rounded col-span-2"></div>
                <div class="h-2 bg-slate-700 rounded col-span-1"></div>
              </div>
              <div class="h-2 bg-slate-700 rounded"></div>
            </div>
          </div>
        </div>
      </div>
      <div class="border border-blue-300 shadow rounded-md p-4 mb-4 max-w-sm w-full mx-auto">
        <div class="animate-pulse flex space-x-4">
          <div class="flex-1 space-y-6 py-1">
            <div class="h-2 bg-slate-700 rounded"></div>
            <div class="space-y-3">
              <div class="grid grid-cols-3 gap-4">
                <div class="h-2 bg-slate-700 rounded col-span-2"></div>
                <div class="h-2 bg-slate-700 rounded col-span-1"></div>
              </div>
              <div class="h-2 bg-slate-700 rounded"></div>
            </div>
          </div>
        </div>
      </div>
    <% else %>
      <h3 class="text-2xl mb-6 me-2 dark:text-white w-auto">No estás suscrito a ningún usuario...</h3>
    <% end %>
    """
  end

  @spec mount(any(), any(), any()) :: {:ok, any()}
  def mount(_params, _session, socket) do
    user_list = parse_user_list(get_users())

    socket = assign(socket, users: user_list, user_logs: [], page: "follow", searching: false)

    {:ok, socket}
  end

  @spec handle_info({:follow_logs, any()} | {:update_users, any(), integer()}, any()) ::
          {:noreply, any()}
  def handle_info({:update_users, new_user, index}, socket) do
    users =
      socket.assigns.users
      |> List.replace_at(index, new_user)

    subs_users = parse_suscribe_users(users)
    subscribe_users(subs_users, self())

    user_logs = optimist_logs(socket.assigns.user_logs, subs_users)
    search = if subs_users == [], do: false, else: true
    socket = assign(socket, users: users, user_logs: user_logs, searching: search)

    {:noreply, socket}
  end

  def handle_info({:response, logs}, socket) do
    IO.inspect(logs)

    socket = assign(socket, user_logs: logs)
    {:noreply, socket}
  end

  # PRIVATE FUNCTIONS

  defp parse_suscribe_users(user_list) do
    Enum.filter(user_list, fn
      %{follow: false} -> true
      _ -> false
    end)
    |> Enum.map(fn %{user: user} -> user end)
  end

  defp parse_user_list(users) do
    Enum.map(users, fn user ->
      %{user: user, follow: true}
    end)
  end

  defp optimist_logs(user_logs, users_sub) do
    Enum.flat_map(users_sub, fn user ->
      Enum.filter(user_logs, fn %{user: u} -> u == user end)
    end)
  end
end
