# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Authorize.Repo.insert!(%Authorize.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Authorize.Core.Accounts

users = [
  %{email: "batman@example.com", password: "P4ssword-f0r-You"},
  %{email: "wolverine@example.com", password: "P4ssword-f0r-You"},
  %{email: "hulk@example.com", password: "P4ssword-f0r-You"},
  %{email: "drmanhattan@example.com", password: "P4ssword-f0r-You"},
  %{email: "ironman@example.com", password: "P4ssword-f0r-You"}
]

Enum.map(users, fn user -> Accounts.register_user(user) end)

batman = Accounts.get_user_by_email("batman@example.com")
Accounts.grant_admin(batman)
hulk = Accounts.get_user_by_email("hulk@example.com")
Accounts.grant_admin(hulk)
