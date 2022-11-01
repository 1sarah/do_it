defmodule DoIt.Repo do
  use Ecto.Repo,
    otp_app: :do_it,
    adapter: Ecto.Adapters.Postgres
end
