defmodule Potinho.Transaction.Chargeback do
  import Ecto.Query

  alias Ecto.Multi
  alias Potinho.Transaction
  alias Potinho.Repo
  alias Potinho.User

  def run(transaction_id, user_id) do
    Multi.new()
    |> Multi.run(:get_transaction_step, get_transaction(transaction_id, user_id))
    |> Multi.run(:verify_charback_step, &verify_charback/2)
    |> Multi.run(:verify_balance_reciever_step, &verify_balance_reciever_for_chargeback/2)
    |> Multi.run(:subtract_from_reciever_step, &subtract_from_reciever/2)
    |> Multi.run(:get_sender_step, &get_sender/2)
    |> Multi.run(:add_to_sender_step, &add_to_sender/2)
    |> Multi.run(:update_transaction_register_step, &update_transaction_register/2)
    |> Repo.transaction()
  end

  def get_transaction(transaction_id, user_id) do
    fn repo, _ ->
      query =
        from t in Transaction,
          where: t.id == ^transaction_id and t.user_sender_id == ^user_id,
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

  def verify_charback(_repo, %{
        get_transaction_step: %{
          is_chargeback: is_chargeback
        }
      }) do
    if is_chargeback do
      {:error, :chargeback_already_done}
    else
      {:ok, :transaction_ok_to_run}
    end
  end

  def verify_balance_reciever_for_chargeback(
        repo,
        %{
          get_transaction_step: %{
            amount: amount_transaction,
            user_reciever_id: user_reciever_id
          }
        }
      ) do

    user_reciever = from(user in User,
        where: user.id == ^user_reciever_id,
        lock: "FOR UPDATE NOWAIT"
      )
      |> repo.one()

    if user_reciever.balance.amount < amount_transaction.amount,
      do: {:error, :balance_too_low},
      else: {:ok, {user_reciever, amount_transaction.amount}}
  end

  def subtract_from_reciever(repo, %{
        verify_balance_reciever_step: {user_reciever, amount_transaction}
      }) do
    user_reciever
    |> User.changeset(%{balance: Money.subtract(user_reciever.balance, amount_transaction)})
    |> repo.update()
  end

  defp get_sender(repo, %{
    get_transaction_step: %{user_sender_id: user_sender_id}
  }) do
    case from(user in User,
            where: user.id == ^user_sender_id,
            lock: "FOR UPDATE NOWAIT"
          )
          |> repo.one() do
      nil -> {:error, :user_not_found}
      user_reciever -> {:ok, user_reciever}
    end
  end


  def add_to_sender(repo, %{
        get_sender_step: user_sender,
        verify_balance_reciever_step: {_user_reciever, amount_transaction}
      }) do
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
