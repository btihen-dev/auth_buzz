defmodule Authorize.Buzz.TopicMembers.TopicMember do
  use Ecto.Schema
  import Ecto.Changeset

  alias Authorize.Buzz.Topics.Topic
  alias Authorize.Core.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "topic_members" do
    # field :topic_id, :binary_id
    # field :member_id, :binary_id
    belongs_to :topic, Topic, foreign_key: :topic_id
    belongs_to :member, User, foreign_key: :member_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(topic_member, attrs) do
    topic_member
    |> cast(attrs, [:topic_id, :member_id])
    |> validate_required([:topic_id, :member_id])
    |> unique_constraint(:topic_id, name: :unique_topic_members)
    |> unique_constraint(:member_id, name: :unique_topic_members)
  end
end
