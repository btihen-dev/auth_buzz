defmodule AuthorizeWeb.Admin.AccountsLive do
  use Phoenix.LiveView

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Admin.UsersLive</h1>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
    # {:ok, assign(socket, :any_assigns, value)}
  end
end
