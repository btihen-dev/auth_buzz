defmodule Authorize.Repo do
  use Ecto.Repo,
    otp_app: :authorize,
    adapter: Ecto.Adapters.Postgres
end
