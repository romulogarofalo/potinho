defmodule Potinho.Repo do
  use Ecto.Repo,
    otp_app: :potinho,
    adapter: Ecto.Adapters.Postgres

    use ExAudit.Repo
end
