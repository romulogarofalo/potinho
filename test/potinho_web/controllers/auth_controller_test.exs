defmodule PotinhoWeb.AuthControllerTest do
  use ExUnit.Case
  use PotinhoWeb.ConnCase

  alias Potinho.User.Create

  describe "/api/login" do
    test "with ok params", %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      Create.run(params)

      params = %{
        "cpf" => cpf,
        "password" => password
      }

      response =
        conn
        |> post(Routes.auth_path(conn, :login), params)
        |> json_response(200)

      assert %{"message" => "Login susseful", "token" => _} = response
    end

    test "with user that not exists", %{conn: conn} do
      params = %{
        "cpf" => "123123123",
        "password" => "batatinha"
      }

      response =
        conn
        |> post(Routes.auth_path(conn, :login), params)
        |> json_response(400)

      assert %{"message" => "bad_request"} == response
    end

    test "when send wrong params to login", %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      Create.run(params)

      params = %{
        "cpf" => cpf,
        "password" => "batatinha"
      }

      response =
        conn
        |> post(Routes.auth_path(conn, :login), params)
        |> json_response(400)

      assert %{"message" => "invalid_credentials"} == response
    end
  end
end
