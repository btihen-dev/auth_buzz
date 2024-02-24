defmodule AuthorizeWeb.Router do
  use AuthorizeWeb, :router

  import AuthorizeWeb.Access.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AuthorizeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AuthorizeWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", AuthorizeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:authorize, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AuthorizeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/access", AuthorizeWeb.Access, as: :access do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AuthorizeWeb.Access.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/access", AuthorizeWeb.Access, as: :access do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AuthorizeWeb.Access.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/access", AuthorizeWeb.Access, as: :access do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AuthorizeWeb.Access.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  ## Admin Routes

  # page available to everyone
  # scope "/admin", AuthorizeWeb.Admin do
  #   pipe_through [:browser]
  #   live("/accounts", AccountsLive, :index)
  # end

  # must be logge in - checked via route plugs only (no live session created)
  # scope "/admin", AuthorizeWeb.Admin do
  #   pipe_through [:browser, :require_authenticated_user]
  #   live("/accounts", AccountsLive, :index)
  # end

  # must be logge in - checked via route plugs only (with a named live session)
  # scope "/admin", AuthorizeWeb.Admin do
  #   pipe_through [:browser, :require_authenticated_user]
  #   # session name `:admin_live` is unimportant, but must be unique
  #   live_session :admin_live do
  #     live("/accounts", AccountsLive, :index)
  #   end
  # end

  # must be logged in and protected via route and liveview session
  # scope "/admin", AuthorizeWeb.Admin, as: :admin do
  #   pipe_through [:browser, :require_authenticated_user]
  #   live_session :admin_live,
  #     on_mount: [{AuthorizeWeb.Access.UserAuth, :ensure_authenticated}] do
  #     live("/accounts", AccountsLive, :index)
  #     # Add other live routes here that require the same authentication
  #   end
  # end

  # must be logged in and authorized as an admin - protected via routes and livesession
  scope "/admin", AuthorizeWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]

    live_session :admin_live,
      on_mount: [
        {AuthorizeWeb.Access.UserAuth, :ensure_authenticated},
        {AuthorizeWeb.Access.UserAuth, :ensure_admin}
      ] do
      live("/accounts", AccountsLive, :index)
      # Add other live routes here that require the same authentication
    end
  end
end
