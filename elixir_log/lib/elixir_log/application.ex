defmodule ElixirLog.Application do
  use Application

  @impl true
  def start(_type, _args) do
    init_children = Application.get_env(:elixir_log, :init_children, true)

    children =
      if init_children do
        [
          %{id: Repository, start: {Repository, :start_link, []}},
          %{id: DataBase, start: {DataBase, :start_link, []}},
          %{id: Filters, start: {Filters, :start_link, []}},
          %{id: SubscriptionManager, start: {SubscriptionManager, :start_link, []}}
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: ElixirLog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
