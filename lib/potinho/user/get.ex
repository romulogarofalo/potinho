defmodule Potinho.User.Get do
  alias Potinho.Repo
  alias Potinho.User

  def user_from_cpf(%{cpf: cpf}) do
    user = Repo.get_by(User, %{cpf: cpf})

    if not is_nil(user) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  def balance(user_id) do
    user = Repo.get!(User, %{id: user_id})

    if not is_nil(user) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end
end
