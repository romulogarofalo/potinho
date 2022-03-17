defmodule Potinho.Auth.Authenticate do
  alias Potinho.User.Get
  alias Potinho.Guardian
  alias Potinho.User

  @spec run(%{cpf: String.t(), password: String.t()}) ::
          {:ok, binary}
          | {:error, :invalid_credentials}
          | {:error, :not_found}
  def run(params) do
    with {:ok, %User{password_hash: password_hash = user}} <- Get.user_from_cpf(params),
         {:ok, true} <- check_password_hash(password_hash, params),
         {:ok, token, _decoded} <- Guardian.encode_and_sign(user) do
      {:ok, token}
    else
      {:error, :not_found} ->
        {:error, :not_found}

      {:error, false} ->
        {:error, :invalid_credentials}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp check_password_hash(password_hash, %{password: password}) do
    if Bcrypt.verify_pass(password, password_hash) do
      {:ok, true}
    else
      {:error, :invalid_credentials}
    end
  end
end
