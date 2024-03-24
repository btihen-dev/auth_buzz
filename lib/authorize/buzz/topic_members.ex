defmodule Authorize.Buzz.TopicMembers do
  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias Authorize.Repo

  alias Authorize.Buzz.TopicMembers.TopicMember

  def topic_members_by_id(id) do
    query = from(t in TopicMember, where: t.topic_id == ^id)
    Repo.all(query)
  end
end
