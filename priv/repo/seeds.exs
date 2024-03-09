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
alias Authorize.Admin.Authorized
alias Authorize.Buzz.Topics

users = [
  %{email: "batman@example.com", password: "P4ssword-f0r-You"},
  %{email: "wolverine@example.com", password: "P4ssword-f0r-You"},
  %{email: "hulk@example.com", password: "P4ssword-f0r-You"},
  %{email: "drmanhattan@example.com", password: "P4ssword-f0r-You"},
  %{email: "ironman@example.com", password: "P4ssword-f0r-You"}
]

Enum.map(users, fn user -> Accounts.register_user(user) end)

batman = Accounts.get_user_by_email("batman@example.com")
hulk = Accounts.get_user_by_email("hulk@example.com")
Authorized.grant_admin(batman)
Authorized.grant_admin(hulk)

topics = [
  %{title: "cats"},
  %{title: "dogs"}
]
Enum.map(topics, fn topic -> Topics.create_topic(topic) end)
