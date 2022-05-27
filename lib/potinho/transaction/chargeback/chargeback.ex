defmodule Potinho.Transaction.Chargeback do
  import Ecto.Query

  alias Ecto.Multi
  alias Potinho.Transaction
  alias Potinho.Repo
  alias Potinho.User

  def run(transaction_id, user_id) do
    Multi.new()
    |> Multi.run(:get_transaction_step, get_transaction(transaction_id, user_id))
    |> Multi.run(:verify_balance_step, &check_balance_for_chargeback/2)
    |> Multi.run(:subtract_from_reciever_step, &subtract_from_reciever/2)
    |> Multi.run(:add_to_sender_step, &add_to_sender/2)
    |> Multi.run(:update_transaction_register_step, &update_transaction_register/2)
    |> Repo.transaction()
  end

  def get_transaction(transaction_id, user_id) do
    fn repo, _ ->
      query =
        from t in Transaction,
          where: t.id == ^transaction_id and t.user_sender_id == ^user_id,
          preload: [:user_sender, :user_reciever],
          lock: "FOR UPDATE NOWAIT"

      query
      |> repo.one()
      |> case do
        nil ->
          {:error, :transaction_not_found}
          transaction ->
            {:ok, transaction}
          end
    end
  end

  def check_balance_for_chargeback(_repo,
    %{
      get_transaction_step: %{
        amount: amount_transaction,
        user_reciever: %{
          balance: %{amount: reciever_amount}
        } = user_reciever,
        user_sender: user_sender
      }
    }) do
      if reciever_amount < amount_transaction.amount,
        do: {:error, :balance_too_low},
        else: {:ok, {user_sender, user_reciever, amount_transaction.amount}}
  end

  def subtract_from_reciever(repo, %{verify_balance_step: {_user_sender, user_reciever, amount_transaction}}) do
    user_reciever
    |> User.changeset(%{balance: Money.subtract(user_reciever.balance, amount_transaction)})
    |> repo.update()
  end

  def add_to_sender(repo, %{verify_balance_step: {user_sender, _user_reciever, amount_transaction}}) do
    user_sender
    |> User.changeset(%{balance: Money.add(user_sender.balance, amount_transaction)})
    |> repo.update()
  end

  def update_transaction_register(repo, %{get_transaction_step: transaction}) do
    transaction
    |> Transaction.changeset(%{is_chargeback: true})
    |> repo.update()
  end
end
