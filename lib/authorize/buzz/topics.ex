defmodule Authorize.Buzz.Topics do
  @moduledoc """
  The Topics context.
  """
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
    Repo.all(Topic)
    |> Repo.preload(:topic_members) # load has many association
    |> Repo.preload(topic_members: :member) # load join table association
    |> Repo.preload(:members) # load the actual desired association (model)
    # |> Repo.preload([:topic_members, [topic_members: :member], :members])
  end

  def new_topic() do
    %Topic{}
    |> Repo.preload(:topic_members)
    |> Repo.preload([topic_members: :member])
    |> Repo.preload(:members)
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
  end

  def new_topic() do
    %Topic{}
    |> Repo.preload(:topic_members)
    |> Repo.preload([topic_members: :member])
    |> Repo.preload(:members)
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
    topic_changeset =
      new_topic()
      |> Topic.changeset(attrs)
      |> Repo.insert()

    {:ok, topic} = topic_changeset
    member_ids = Map.get(attrs, "member_ids") || []
    if is_list(member_ids) && !Enum.empty?(member_ids) do
      topic_members =
        Enum.map(member_ids, fn member_id ->
          now = DateTime.utc_now() |> DateTime.truncate(:second)
          %{topic_id: topic.id, member_id: member_id, inserted_at: now, updated_at: now}
        end)
      Repo.insert_all(TopicMember, topic_members)
    end

    # reload since added members after initial save
    topic = get_topic!(topic.id)
    {:ok, topic}
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
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()

    # Delete all members
    topic_members = TopicMembers.topic_members_by_id(topic.id)
    if is_list(topic_members) && !Enum.empty?(topic_members) do
      from(t in TopicMember, where: t.topic_id == ^topic.id) |> Repo.delete_all()
    end

    # rebuild members with the new ones
    member_ids = Map.get(attrs, "member_ids") || []
    if is_list(member_ids) && !Enum.empty?(member_ids) do
      topic_members =
        Enum.map(member_ids, fn member_id ->
          now = DateTime.utc_now() |> DateTime.truncate(:second)
          %{topic_id: topic.id, member_id: member_id, inserted_at: now, updated_at: now}
        end)
      Repo.insert_all(TopicMember, topic_members)
    end

    # reload since added members after initial save
    topic = get_topic!(topic.id)
    {:ok, topic}
  end

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
