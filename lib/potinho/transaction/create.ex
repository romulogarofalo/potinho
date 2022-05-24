defmodule Potinho.Transaction.Create do

  alias Ecto.Multi
  alias Potinho.User
  alias Potinho.Transaction
  import Ecto.Query, only: [from: 2]

  def run(user_sender, user_reciever, amount) do
    Multi.new()
    |> Multi.run(:retrieve_users_step, get_users(user_sender, user_reciever))
    |> Multi.run(:verify_balances_step, verify_balances(amount))
    |> Multi.run(:subtract_from_a_step, &subtract_from_sender/2)
    |> Multi.run(:add_to_b_step, &add_to_reciever/2)
    |> Multi.run(:create_transaction_register, &create_transaction/2)
    |> Repo.transaction()
  end

  defp get_users(user_sender_cpf, user_reciever_cpf) do
    fn repo, _ ->
      case from(user in User, where: user.cpf in [^user_sender_cpf, ^user_reciever_cpf],
      lock: "FOR UPDATE NOWAIT") |> repo.all() do
        [user_a, user_b] -> {:ok, {user_a, user_b}}
        _ -> {:error, :user_not_found}
      end
    end
  end

  defp verify_balances(transfer_amount) do
    fn _repo, %{retrieve_users_step: {user_sender, user_reciever}} ->
      if user_sender.balance < transfer_amount,
        do: {:error, :balance_too_low},
        else: {:ok, {user_sender, user_reciever, transfer_amount}}
    end
  end

  defp subtract_from_sender(repo, %{verify_balances_step: {user_sender, _, verified_amount}}) do
    user_sender
    |> User.changeset(%{balance: user_sender.balance - verified_amount})
    |> repo.update()
  end

  defp add_to_reciever(repo, %{verify_balances_step: {_, user_reciever, verified_amount}}) do
    user_reciever
    |> User.changeset(%{balance: user_reciever.balance + verified_amount})
    |> repo.update()
  end

  defp create_transaction(repo, %{verify_balances_step: {user_sender, user_reciever, verified_amount}}) do
    Transaction.create_changeset(
      %{
        user_sender: user_sender,
        user_reciever: user_reciever,
        amount: verified_amount
      }
    )
    repo.insert()
  end
end
