defmodule AuthorizeWeb.Admin.TopicLive.Show do
  use AuthorizeWeb, :live_view

  alias Authorize.Buzz.Topics
  alias Authorize.Admin.Authorized

  @impl true
  def mount(_params, _session, socket) do
    users = Authorized.list_users()
    socket = assign(socket, :users, users)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:topic, Topics.get_topic!(id))}
  end

  defp page_title(:show), do: "Show Topic"
  defp page_title(:edit), do: "Edit Topic"
end
