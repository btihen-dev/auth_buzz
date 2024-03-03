defmodule AuthorizeWeb.Admin.AdminRolesLive do
  use Phoenix.LiveView
  alias Authorize.Core.Accounts
  alias Authorize.Core.Accounts.User
  alias Authorize.Admin.Authorized

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-4xl text-center">Admin</h1>
    <p class="text-center">total users: <%= @users |> Enum.count() %></p>
    <div style="margin-top: 20px;">
      <table class="mx-auto">
        <tr>
          <th class="px-4 py-2">Email</th>
          <th class="px-4 py-2">Roles</th>
          <th class="px-4 py-2">Action</th>
        </tr>
        <%= for user <- @users do %>
          <tr class={if rem(Enum.find_index(@users, &(&1 == user)), 2) == 0, do: "bg-gray-100"}>
            <%= if User.admin?(user) do %>
              <td class="px-4 py-2 font-bold text-red-800"><%= user.email %></td>
            <% else %>
              <td class="px-4 py-2"><%= user.email %></td>
            <% end %>
            <td class="px-4 py-2"><%= user.roles |> Enum.join(", ") %></td>
            <td class="px-4 py-2 text-right">
              <!-- no need to gran admin to an admin -->
              <button
                :if={!User.admin?(user)}
                phx-click="grant"
                phx-value-id={user.id}
                class="mr-2 bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"
              >
                Grant
              </button>
              <!-- don't show revoke to current user and only to those who are already admins -->
              <button
                :if={@current_user.id != user.id && User.admin?(user)}
                phx-click="revoke"
                phx-value-id={user.id}
                class="bg-orange-500 hover:bg-orange-700 text-white font-bold py-2 px-4 rounded"
              >
                Revoke
              </button>
              <button
                :if={@current_user.id != user.id}
                phx-click="delete"
                phx-value-id={user.id}
                class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
                onclick="return confirm('Are you sure you want to delete this item?');"
              >
                Delete
              </button>
            </td>
          </tr>
        <% end %>
      </table>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to a PubSub topic (if connected - mount happen twice -
    # once for initial load and once to do liveView socket connection)
    if connected?(socket), do: Authorized.subscribe("authorized:admin_role_updates")

    {:ok, assign(socket, users: Authorized.list_users())}
  end

  @impl true
  def handle_info({:admins_updated, users}, socket) do
    socket = assign(socket, users: users)
    {:noreply, socket}
  end

  @impl true
  def handle_event("grant", %{"id" => id}, socket) do
    Authorized.grant_admin(id)
    {:noreply, assign(socket, users: Authorized.list_users())}
  end

  @impl true
  def handle_event("revoke", %{"id" => id}, socket) do
    Authorized.revoke_admin(id)
    {:noreply, assign(socket, users: Authorized.list_users())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Authorized.delete_user(id)
    {:noreply, assign(socket, users: Authorized.list_users())}
  end
end
