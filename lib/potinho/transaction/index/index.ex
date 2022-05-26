defmodule Potinho.Transaction.Index do
  alias Potinho.User
  alias Potinho.Repo
  import Ecto.Query

  def run(user_id, initial_date, end_date) do
    from(u in User,
      where: u.user_reciever_id == ^user_id,
      where: ^initial_date > u.updated_at,
      where: ^end_date < u.updated_at
    )
    |> Repo.all()
  end
end
