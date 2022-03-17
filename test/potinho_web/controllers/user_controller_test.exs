defmodule PotinhoWeb.UserControllerTest do
  use ExUnit.Case

  use PotinhoWeb.ConnCase

  alias Potinho.Repo
  alias Potinho.User

  describe "/api/signup" do
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

      conn = post(conn, Routes.user_path(conn, :create), params)

      assert conn.status == 201

      assert conn.resp_body =~
               "{\"message\":\"User Created\",\"user\":{\"cpf\":\"#{cpf}\",\"full_name_user\":\"#{full_name}\""

      [
        %{
          cpf: ^cpf,
          full_name_user: ^full_name,
          password_hash: password_hash,
          balance: balance
        }
      ] = Repo.all(User)

      assert balance == %Money{amount: 100_050, currency: :BRL}
      assert Bcrypt.verify_pass(password, password_hash)
    end

    test "when insert repeated user", %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      post(conn, Routes.user_path(conn, :create), params)
      conn = post(conn, Routes.user_path(conn, :create), params)

      assert conn.status == 409
      assert conn.resp_body =~ "conflict"

      [
        %{
          cpf: ^cpf,
          full_name_user: ^full_name,
          password_hash: password_hash,
          balance: balance
        }
      ] = Repo.all(User)

      assert balance == %Money{amount: 100_050, currency: :BRL}
      assert Bcrypt.verify_pass(password, password_hash)
    end

    test "when insert with empty body", %{conn: conn} do
      params = %{
        "full_name_user" => "",
        "password" => "",
        "cpf" => ""
      }

      post(conn, Routes.user_path(conn, :create), params)
      conn = post(conn, Routes.user_path(conn, :create), params)

      assert conn.status == 400
      assert conn.resp_body =~ "bad_request"

      assert [] == Repo.all(User)
    end
  end
end
