defmodule FrontWeb.LogsComponents do
  use Phoenix.Component

  attr :user_name, :string
  attr :user_logs, :list

  def card_logs(assigns) do
    ~H"""
    <%= for  %{ "date_time" => log_d, "log" => log_m, "service" => log_s } <- @user_logs do %>
      <.log_card log_user={@user_name} log_date={log_d} log_message={log_m} log_service={log_s} />
    <% end %>
    """
  end

  attr :log_user, :string
  attr :log_date, :string
  attr :log_message, :string
  attr :log_service, :string

  def log_card(assigns) do
    ~H"""
    <div class="block  p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700">
      <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
        <%= @log_user %>
      </h5>
      <h6 class="mb-2 text-base font-medium leading-tight text-surface/75 dark:text-neutral-300">
        Fecha: <%= @log_date %>
      </h6>
      <p class="font-normal text-gray-700 dark:text-gray-400">
        <%= @log_service %>: <%= @log_message %>
      </p>
    </div>
    """
  end

  attr :user_name, :list
  attr :user_logs, :list

  def subs_logs(assigns) do
    ~H"""
    <div class="w-full mb-4 w-full p-4 bg-white border border-gray-200 rounded-lg shadow sm:p-5 dark:bg-gray-800 dark:border-gray-700">
      <div class="flex items-center justify-between mb-4">
        <h5 class="text-xl font-bold leading-none text-gray-900 dark:text-white">
          <%= @user_name %>
        </h5>
      </div>
      <div class="flow-root">
        <ul role="list" class="divide-y divide-gray-200 dark:divide-gray-700">
          <%= for  %{"date_time" => log_d, "log" => log_m, "service" => log_s } <- @user_logs do %>
            <.log_elem log_date={log_d} log_message={log_m} log_service={log_s} />
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  attr :log_date, :string
  attr :log_message, :string
  attr :log_service, :string

  def log_elem(assigns) do
    ~H"""
    <li class="py-3 sm:py-4 ">
      <div class="flex items-center">
        <div class="flex-1 min-w-0 ms-4">
          <p class="text-sm font-medium text-gray-900 truncate dark:text-white">
            <%= @log_service %>
          </p>
          <p class="text-sm text-gray-500 truncate dark:text-gray-400">
            <%= @log_date %>
          </p>

          <div class="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
            <%= @log_message %>
          </div>
        </div>
      </div>
    </li>
    """
  end
end
