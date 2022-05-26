defmodule Potinho.Transaction.Chargeback do
  import Ecto.Query

  alias Ecto.Multi
  alias Potinho.Transaction
  alias Potinho.Repo

  def run(transaction_id, user_id) do
    Multi.new()
    |> Multi.run(:get_transaction_step, get_transaction(transaction_id, user_id))
    |> Multi.run(:verify_balance_step, &check_balance_for_chargeback/2)
    |> Multi.run(:subtract_from_reciever_step, &check_balance_for_chargeback/2)
    |> Multi.run(:add_to_reciever_sender_step, &check_balance_for_chargeback/2)
    |> Multi.run(:update_transaction_register, &check_balance_for_chargeback/2)

    %{
      user_reciever: user_reciever,
      user_sender: user_sender,
      amount: amount
    } = get_transaction(transaction_id, user_id)

    check_balance_for_chargeback(user_reciever, amount)

  end

  def get_transaction(transaction_id, user_id) do
    query =
      from t in Transaction,
        where: t.id == ^transaction_id and t.user_sender_id == ^user_id,
        preload: [:user_sender, :user_reciever],
        lock: "FOR UPDATE NOWAIT"

    # TO-DO: see how to update with no share for preloads
    query
    |> Repo.one()
    |> case do
      nil ->
        {:error, :transaction_not_found}
      transaction ->
        {:ok, transaction}
    end
  end

  def check_balance_for_chargeback() do
    fn _repo,
      %{
        get_transaction_step: %{

        }
      }
    ->

        if reciever_amount > amount_transaction do

        else
          # nao da pra fazer
        end

  end
end
