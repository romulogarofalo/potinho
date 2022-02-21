defmodule PotinhoWeb.LoginView do

  def render("login.json", %{token: token}) do
    %{
      message: "Login susseful",
      token: token
    }
  end
end
