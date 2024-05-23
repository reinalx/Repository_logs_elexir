defmodule FrontWeb.Router do
  use FrontWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {FrontWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", FrontWeb do
    pipe_through(:browser)

    live("/", LogsLive)
    live("/followLogs", FollowLive)
  end
end
