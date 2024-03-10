defmodule Authorize.Repo.Migrations.CreateTopicMembers do
  use Ecto.Migration

  def change do
    create table(:topic_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :topic_id, references(:topics, on_delete: :nothing, type: :binary_id)
      add :member_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:topic_members, [:topic_id, :member_id])
    create index(:topic_members, [:topic_id])
    create index(:topic_members, [:member_id])
  end
end
