defmodule FrontWeb.LiveComponents.LogUserList do
  use FrontWeb, :live_component

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="w-full mb-4 max-w-md p-4 bg-white border border-gray-200 rounded-lg shadow sm:p-5 dark:bg-gray-800 dark:border-gray-700">
      <div class="flex items-center justify-between mb-4">
        <h5 class="text-xl font-bold leading-none text-gray-900 dark:text-white">
          <%= @user_name %>
        </h5>
      </div>
      <div class="flow-root">
        <ul role="list" class="divide-y divide-gray-200 dark:divide-gray-700">
          <%= for  %{date_time: log_d, log: log_m, service: log_s } <- @user_logs do %>
            <.log_elem log_date={log_d} log_message={log_m} log_service={log_s} />
          <% end %>
        </ul>
      </div>
    </div>
    """
  end
end
