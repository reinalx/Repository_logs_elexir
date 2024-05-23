defmodule FrontWeb.LiveLogComponents do
  use FrontWeb, :live_component

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="w-full max-w-md p-4 bg-white border border-gray-200 rounded-lg shadow sm:p-5 dark:bg-gray-800 dark:border-gray-700">
      <div class="flex items-center justify-between mb-4">
        <h5 class="text-xl font-bold leading-none text-gray-900 dark:text-white">User List</h5>
      </div>
      <div class="flow-root">
        <ul role="list" class="divide-y divide-gray-200 dark:divide-gray-700">
          <%= for  {%{user: user_n, follow: isFollowing}, index} <- Enum.with_index(@users_list) do %>
            <.user_account user_name={user_n} follow={isFollowing} index={index} mySelf={@myself} />
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  attr :user_name, :string
  attr :follow, :boolean
  attr :index, :integer
  attr :mySelf, :any

  @spec user_account(map()) :: Phoenix.LiveView.Rendered.t()
  def user_account(assigns) do
    ~H"""
    <li class="py-3 transition-all	 sm:py-4 ">
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <img
            class="w-14 h-14 rounded-lg shadow-lg"
            src={"https://unavatar.io/twitter/#{@user_name}"}
            alt="Neil image"
          />
        </div>
        <div class="flex-1 min-w-0 ms-4">
          <p class="text-sm font-medium text-gray-900 truncate dark:text-white">
            <%= @user_name %>
          </p>
        </div>
        <%= if @follow == true do %>
          <button
            phx-click="update_follow"
            phx-target={@mySelf}
            phx-value-usr={@user_name}
            phx-value-fol={boolean_to_string(@follow)}
            phx-value-index={@index}
            class=" inline-flex items-center text-base font-semibold relative inline-flex items-center justify-center p-0.5 mb-2 me-2 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-green-400 to-blue-600 group-hover:from-green-400 group-hover:to-blue-600 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-green-200 dark:focus:ring-green-800"
          >
            <span class="relative px-6 py-1 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0">
              Follow
            </span>
          </button>
        <% else %>
          <button
            phx-click="update_follow"
            phx-target={@mySelf}
            phx-value-usr={@user_name}
            phx-value-fol={boolean_to_string(@follow)}
            phx-value-index={@index}
            class="inline-flex items-center text-base font-semibold relative inline-flex items-center justify-center p-0.5 mb-2 me-2 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-pink-500 to-orange-400 group-hover:from-pink-500 group-hover:to-orange-400 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-pink-200 dark:focus:ring-pink-800"
          >
            <span class="relative px-3.5 py-1  transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0">
              Unfollow
            </span>
          </button>
        <% end %>
      </div>
    </li>
    """
  end

  # Refactorizar esto
  def boolean_to_string(true), do: "true"
  def boolean_to_string(false), do: "false"
  def string_to_boolean("true"), do: true
  def string_to_boolean("false"), do: false

  @spec handle_event(<<_::88, _::_*16>>, any(), map()) :: {:noreply, map()}
  def handle_event(
        "update_follow",
        %{"usr" => user_n, "fol" => isFollowing, "index" => index},
        socket
      ) do
    new_user = %{
      user: user_n,
      follow: not string_to_boolean(isFollowing)
    }

    send(self(), {:update_users, new_user, String.to_integer(index)})
    {:noreply, socket}
  end
end
