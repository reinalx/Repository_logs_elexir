defmodule FrontWeb.LogsLive do
  use FrontWeb, :live_view

  import FrontWeb.GetLogs,
    only: [
      get_logs_repo: 2,
      get_filter_keyword: 1,
      get_filter_service: 1,
      get_all_logs: 0,
      get_filters_redo: 0
    ]

  def render(assigns) do
    ~H"""
    <section>
      <header class="flex flex-col  justify-between">
        <h2 class=" text-4xl mb-3 me-2 dark:text-white">Busqueda de Logs</h2>

        <form phx-submit="search" class="flex flex-wrap items-end space-x-4 mb-4">
          <div>
            <label
              for="number-input"
              class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
            >
              Last minutes:
            </label>
            <span class="relative inline-flex items-center justify-center p-0.5  overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800">
              <input
                type="number"
                id="number-input"
                min="0"
                max="60"
                name="minutes"
                aria-describedby="helper-text-explanation"
                class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                placeholder="32"
                required
              />
            </span>
          </div>
          <div>
            <label
              for="number-input"
              class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
            >
              Users:
            </label>
            <span class="relative inline-flex items-center justify-center p-0.5  overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800">
              <input
                type="text"
                id="list_users"
                name="users"
                class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-96 p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                placeholder="miguel, juan, andres, santiago,..."
                required
              />
            </span>
          </div>
          <div class="flex-1"></div>
          <!-- Espacio flexible para empujar el botón a la derecha -->
          <button
            type="button"
            phx-click="all"
            class="relative inline-flex items-center justify-center p-0.5 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800"
          >
            <span class="relative px-5 py-2.5 max-w-48 w-fulltransition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0">
              All
            </span>
          </button>
          <button
            type="submit"
            class=" max-w-36 w-full inline-flex  self-end p-0.5 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800"
          >
            <span
              phx-disable-with="Loading..."
              class=" w-full px-5 py-2.5  transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0"
            >
              Buscar
            </span>
          </button>
        </form>
        <h3 class=" text-3xl mb-2 me-2 dark:text-white">Filtros</h3>
        <form phx-submit="filter" class="flex flex-wrap items-end space-x-4 mb-4">
          <span class="relative inline-flex items-center justify-center p-0.5 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800">
            <input
              class="w-64 bg-gray-50 border    border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block  p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500 "
              name="keyword"
              type="text"
              placeholder="ocurred,completed..."
            />
          </span>
          <span class="relative inline-flex items-center justify-center p-0.5  overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800">
            <input
              class=" w-64 bg-gray-50 border  border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block  p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500 "
              name="service"
              type="text"
              placeholder="Apache, syslog,..."
            />
          </span>

          <div class="flex-1"></div>
          <button
            type="button"
            class="relative inline-flex items-center justify-center p-0.5 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800"
          >
            <span
              phx-click="redo"
              class="relative px-5 py-2.5 max-w-48 w-fulltransition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0"
            >
              Redo
            </span>
          </button>
          <button
            type="submit"
            class=" max-w-36 w-full inline-flex self-end p-0.5 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800"
          >
            <span
              phx-disable-with="Loading..."
              class="  w-full px-5 py-2.5 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0"
            >
              Filtrar
            </span>
          </button>
        </form>
      </header>
      <%= if @filters != [] do %>
        <aside>
          <header>
            <h5 class="mb-2 text-lg font-semibold text-gray-900 dark:text-white">
              Applied filters:
            </h5>
            <ul class="max-w-md mb-4 space-y-1 text-gray-500 list-disc list-inside dark:text-gray-400">
              <%= for  filter <- @filters do %>
                <li><%= filter %></li>
              <% end %>
            </ul>
          </header>
        </aside>
      <% end %>

      <%= for  %{user: user_n, logs: user_l} <- @logs do %>
        <.card_logs user_name={user_n} user_logs={user_l} />
      <% end %>
    </section>
    """
  end

  # falta hacer el reenderizado condicional

  @spec mount(any(), any(), any()) :: {:ok, any()}
  def mount(_params, _session, socket) do
    socket = assign(socket, logs: get_all_logs(), page: "home", filters: [])
    {:ok, socket}
  end

  @spec handle_event(<<_::88>>, any(), map()) :: {:noreply, map()}
  def handle_event("filter", %{"keyword" => keyword, "service" => service}, socket) do
    new_logs = if keyword != "", do: get_filter_keyword(keyword)

    new_logs = if service != "", do: get_filter_service(service), else: new_logs

    socket = assign(socket, logs: new_logs || socket.assign.logs)

    socket =
      if keyword != "",
        do: update(socket, :filters, fn filter -> filter ++ [keyword] end),
        else: socket

    socket =
      if service != "",
        do: update(socket, :filters, fn filter -> filter ++ [service] end),
        else: socket

    {:noreply, socket}
  end

  def handle_event("redo", _value, socket) do
    socket = update(socket, :filters, fn filters -> List.delete(filters, List.last(filters)) end)
    {:noreply, assign(socket, logs: get_filters_redo())}
  end

  def handle_event("search", %{"minutes" => min, "users" => users}, socket) do
    user_list = parse_names(users)
    {minutes, _} = Integer.parse(min)

    socket =
      assign(socket, logs: get_logs_repo(minutes, user_list))
      |> assign(filters: [])

    {:noreply, socket}
  end

  def handle_event("all", _value, socket) do
    {:noreply, assign(socket, logs: get_all_logs())}
  end

  defp parse_names(names_string) do
    String.split(names_string, ",", trim: true)
  end
end
