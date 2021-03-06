defmodule PotinhoWeb.UserView do
  def render("created.json", %{user: user}) do
    %{
      message: "User Created",
      user: %{
        id: user.id,
        cpf: user.cpf,
        full_name_user: user.full_name_user,
        inserted_at: user.inserted_at
      }
    }
  end

  def render("show.json", %{user: user}) do
    %{
      user: %{
        cpf: user.cpf,
        balance: user.balance,
        full_name_user: user.full_name_user
      }
    }
  end
end
