defmodule AuthorizeWeb.Admin.TopicLive.FormComponent do
  use AuthorizeWeb, :live_component

  alias Authorize.Buzz.Topics

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage topic records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="topic-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <select name="members[]" multiple id="members" class="form-control">
          <%= for user <- @users do %>
            <%= selected = user.id in Enum.map(@topic.members, & &1.id) %>
            <option value={user.id} selected={selected}><%= user.email %></option>
          <% end %>
        </select>

        <:actions>
          <.button phx-disable-with="Saving...">Save Topic</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{topic: topic} = assigns, socket) do
    changeset = Topics.change_topic(topic)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate",  params, socket) do
    topic_params = Map.get(params, "topic")
    member_ids = Map.get(params, "members") || []
    params = Map.put(topic_params, "member_ids", member_ids)

    changeset =
      socket.assigns.topic
      |> Topics.change_topic(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    topic_params = Map.get(params, "topic")
    member_ids = Map.get(params, "members") || []
    params = Map.put(topic_params, "member_ids", member_ids)

    save_topic(socket, socket.assigns.action, params)
  end

  defp save_topic(socket, :edit, params) do
    IO.inspect(params, label: "save_topic params")
    saved_topic = Topics.update_topic(socket.assigns.topic, params)

    case saved_topic do
      {:ok, topic} ->
        notify_parent({:saved, topic})

        {:noreply,
         socket
         |> put_flash(:info, "Topic updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_topic(socket, :new, params) do
    new_topic = Topics.create_topic(params)

    case new_topic do
      {:ok, topic} ->
        notify_parent({:saved, topic})

        {:noreply,
         socket
         |> put_flash(:info, "Topic created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
