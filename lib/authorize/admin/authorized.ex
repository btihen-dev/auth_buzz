defmodule Authorize.Admin.Authorized do
  import Ecto.Query, warn: false
  alias Authorize.Repo
  alias Authorize.Core.Accounts
  alias Authorize.Core.Accounts.User

  # Authorized PubSub
  def subscribe("authorized:admin_role_updates") do
    Phoenix.PubSub.subscribe(Authorize.PubSub, "authorized:admin_role_updates")
  end

  def broadcast("authorized:admin_role_updates") do
    Phoenix.PubSub.broadcast(
      Authorize.PubSub,
      "authorized:admin_role_updates",
      {:admins_updated, list_users()}
    )
  end

  # unsorted
  # def list_users(), do: Repo.all(User)
  def list_users(), do: Repo.all(from u in User, order_by: [asc: u.email])

  def delete_user(id) do
    user = Repo.get!(User, id)

    with {:ok, user} <- Repo.delete(user) do
      # Broadcast the update only on success
      broadcast("authorized:admin_role_updates")
      {:ok, user}
    else
      {:error, changeset} ->
        # return(or handle) error
        {:error, changeset}
    end
  end

  # admin management
  def grant_admin(uuid) when is_binary(uuid), do: grant_admin(Accounts.get_user!(uuid))

  def grant_admin(%User{} = user) do
    new_roles =
      ["admin" | user.roles]
      |> Enum.uniq()

    with {:ok, user} <-
           user
           |> User.admin_roles_changeset(%{roles: new_roles})
           |> Repo.update() do
      # Broadcast the update only on success
      broadcast("authorized:admin_role_updates")
      {:ok, user}
    else
      {:error, changeset} ->
        # return(or handle) error
        {:error, changeset}
    end
  end

  def revoke_admin(uuid) when is_binary(uuid), do: revoke_admin(Accounts.get_user!(uuid))

  def revoke_admin(%User{} = user) do
    new_roles = user.roles -- ["admin"]

    with {:ok, user} <-
           user
           |> User.admin_roles_changeset(%{roles: new_roles})
           |> Repo.update() do
      # Broadcast the update only on success
      broadcast("authorized:admin_role_updates")
      # return user like normal
      {:ok, user}
    else
      {:error, changeset} ->
        # return(or handle) error
        {:error, changeset}
    end
  end
end
