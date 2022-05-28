defmodule Potinho.Transaction.Index do
  alias Potinho.Transaction
  alias Potinho.Repo
  import Ecto.Query

  def run(user_id, initial_date, end_date) do
    from(u in Transaction,
      where: u.user_sender_id == ^user_id,
      where: ^initial_date < u.inserted_at,
      where: ^end_date > u.inserted_at,
      preload: [:user_reciever]
    )
    |> Repo.all()
  end
end
