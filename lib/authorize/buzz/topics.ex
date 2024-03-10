defmodule Authorize.Buzz.Topics do
  @moduledoc """
  The Topics context.
  """
  # import Ecto.Multi
  import Ecto.Query, warn: false
  alias Authorize.Repo

  alias Authorize.Buzz.Topics.Topic
  alias Authorize.Buzz.TopicMembers
  alias Authorize.Buzz.TopicMembers.TopicMember

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics do
    Repo.all(Topic) |> Repo.preload(:members)
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id) do
    Repo.get!(Topic, id)
    |> Repo.preload(:topic_members)
    |> Repo.preload(topic_members: :member)
    |> Repo.preload(:members)
    # |> Repo.preload([:topic_members, [topic_members: :member], :members])
    |> IO.inspect(label: "get_topic!")
  end

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(attrs \\ %{}) do
    IO.inspect(attrs, label: "create_topic attrs")
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(%Topic{} = topic, attrs) do
    topic_members = TopicMembers.topic_members_by_id(topic.id)
    if is_list(topic_members) && !Enum.empty?(topic_members) do
      from(t in TopicMember, where: t.topic_id == ^topic.id) |> Repo.delete_all()
    end

    member_ids = Map.get(attrs, "member_ids") || []
    if is_list(member_ids) && !Enum.empty?(member_ids) do
      topic_members =
        Enum.map(member_ids, fn member_id ->
          now = DateTime.utc_now() |> DateTime.truncate(:second)
          %{topic_id: topic.id, member_id: member_id, inserted_at: now, updated_at: now}
        end)
      Repo.insert_all(TopicMember, topic_members)
    end

    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  # def update_topic(%Topic{} = topic, attrs) do
  #   Repo.transaction(fn ->
  #     Ecto.Multi.new()
  #     |> delete_topic_members(topic.id)
  #     |> insert_topic_members(topic.id, Map.get(attrs, "member_ids"))
  #     |> update_topic_multi(topic, attrs)
  #     |> Repo.transaction()
  #   end)
  # end

  # defp delete_topic_members(multi, topic_id) do
  #   topic_members = TopicMembers.topic_members_by_id(topic_id)
  #   if is_list(topic_members) && !Enum.empty?(topic_members) do
  #     Ecto.Multi.delete(multi, :delete_topic_members,
  #       from(t in TopicMember, where: t.topic_id == ^topic_id)
  #     )
  #   else
  #     multi
  #   end
  # end

  # defp insert_topic_members(multi, topic_id, member_ids) do
  #   if is_list(member_ids) && !Enum.empty?(member_ids) do
  #     now = DateTime.utc_now() |> DateTime.truncate(:second)
  #     topic_members =
  #       Enum.map(member_ids, fn member_id ->
  #         %{topic_id: topic_id, member_id: member_id, inserted_at: now, updated_at: now}
  #       end)
  #     Ecto.Multi.insert_all(multi, :insert_topic_members, TopicMember, topic_members)
  #   else
  #     multi
  #   end
  # end

  # defp update_topic_multi(multi, topic, attrs) do
  #   Ecto.Multi.update(multi, :update_topic,
  #     Topic.changeset(topic, attrs)
  #     |> Repo.update()
  #   )
  # end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(topic)
      {:ok, %Topic{}}

      iex> delete_topic(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change_topic(topic)
      %Ecto.Changeset{data: %Topic{}}

  """
  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end
end
