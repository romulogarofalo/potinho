defmodule Potinho.Transaction.Create do
  alias Ecto.Multi
  alias Potinho.User
  alias Potinho.Transaction
  alias Potinho.Repo

  import Ecto.Query, only: [from: 2]

  def run(%{cpf_reciever: cpf_reciever, amount: amount, id_sender: id_sender}) do
    Multi.new()
    |> Multi.run(:get_sender_step, get_sender(id_sender))
    |> Multi.run(:verify_balances_step, verify_balances(amount))
    |> Multi.run(:subtract_from_sender_step, &subtract_from_sender/2)
    |> Multi.run(:get_reciever_step, get_reciever(cpf_reciever))
    |> Multi.run(:add_to_reciever_step, &add_to_reciever/2)
    |> Multi.run(:create_transaction_register, &create_transaction/2)
    |> Repo.transaction()
  end

  defp get_sender(id_sender) do
    fn repo, _ ->
      case from(user in User,
             where: user.id == ^id_sender,
             lock: "FOR UPDATE NOWAIT"
           )
           |> repo.one() do
        nil -> {:error, :user_not_found}
        user_reciever -> {:ok, user_reciever}
      end
    end
  end

  defp get_reciever(cpf_reciever) do
    fn repo, _ ->
      case from(user in User,
             where: user.cpf == ^cpf_reciever,
             lock: "FOR UPDATE NOWAIT"
           )
           |> repo.one() do
        nil -> {:error, :user_not_found}
        user_reciever -> {:ok, user_reciever}
      end
    end
  end

  defp verify_balances(transfer_amount) do
    fn _repo, %{get_sender_step: user_sender} ->
      if user_sender.balance.amount < transfer_amount.amount,
        do: {:error, :balance_too_low},
        else: {:ok, {user_sender, transfer_amount.amount}}
    end
  end

  defp subtract_from_sender(repo, %{verify_balances_step: {user_sender, verified_amount}}) do
    user_sender
    |> User.changeset(%{balance: Money.subtract(user_sender.balance, verified_amount)})
    |> repo.update()
  end

  defp add_to_reciever(repo, %{verify_balances_step: {_, verified_amount}, get_reciever_step: user_reciever}) do
    user_reciever
    |> User.changeset(%{balance: Money.add(user_reciever.balance, verified_amount)})
    |> repo.update()
  end

  defp create_transaction(repo, %{
         verify_balances_step: {user_sender, verified_amount},
         get_reciever_step: user_reciever
       }) do
    Transaction.create_changeset(%{
      user_sender_id: user_sender.id,
      user_reciever_id: user_reciever.id,
      amount: verified_amount
    })
    |> repo.insert(returning: true)
  end
end
