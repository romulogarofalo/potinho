defmodule Potinho.User.Create do
  alias Potinho.Repo
  alias Potinho.User

  @spec run(map()) :: {:ok, Ecto.Changeset} | {:error, Ecto.Changeset}
  def run(params) do
    params
    |> User.create_changeset()
    |> Repo.insert(returning: true)
  end
end
