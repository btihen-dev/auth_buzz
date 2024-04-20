defmodule Authorize.Buzz.Topics.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Authorize.Buzz.TopicMembers.TopicMember

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "topics" do
    field :title, :string

    has_many :topic_members, TopicMember, on_delete: :delete_all
    has_many :members, through: [:topic_members, :member]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
