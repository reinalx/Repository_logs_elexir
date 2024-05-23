defmodule FrontWeb.GetLogs do
  import Filters,
    only: [
      send_logs: 2,
      send_all_logs: 0,
      filter_keywords: 1,
      filter_service: 1,
      filter_redo: 0
    ]

  import SubscriptionManager,
    only: [
      subscribe: 2,
      send_users: 0
    ]

  # Repo functions

  # Logs_live Page
  @spec get_all_logs() :: any()
  def get_all_logs() do
    send_all_logs()
  end

  @spec get_filter_service(binary()) :: any()
  def get_filter_service(service) do
    filter_service(service)
  end

  @spec get_filter_keyword(binary()) :: any()
  def get_filter_keyword(keyword) do
    filter_keywords(keyword)
  end

  @spec get_logs_repo(any(), any()) :: any()
  def get_logs_repo(min, list_users) do
    send_logs(min, list_users)
  end

  def get_filters_redo() do
    filter_redo()
  end

  # Follow live page

  def get_users() do
    send_users()
  end

  def subscribe_users(user_list, pid) do
    subscribe(user_list, pid)
  end
end
