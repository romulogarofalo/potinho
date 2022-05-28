defmodule Potinho.Guardian do
  use Guardian, otp_app: :potinho

  alias Potinho.User.Get
  def subject_for_token(%{cpf: cpf, id: id}, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = Jason.encode!(%{cpf: cpf, id: id})
    {:ok, sub}
  end

  def subject_for_token(data, _) do
    %{"cpf" => cpf} = Jason.decode!(data)
    case Get.user_from_cpf(%{cpf: cpf}) do
      {:ok, %{cpf: cpf, id: id}} ->
        {:ok, Jason.encode!(%{cpf: cpf, id: id})}
      {:error, :not_found} ->
        {:error, :reason_for_error}
    end
  end

  def subject_for_token(_), do: {:error, "Unknown resource type"}

  def resource_from_claims(%{"sub" => sub}) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In above `subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    {:ok, Jason.decode!(sub)}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
