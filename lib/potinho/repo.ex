defmodule Potinho.Repo do
  use Ecto.Repo,
    otp_app: :potinho,
    adapter: Ecto.Adapters.Postgres
end
