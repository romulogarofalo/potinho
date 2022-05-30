# POTINHO (like tupperware)

 🍯 A backend o simulate a bank

## Table of Contents
- [Introduction](#introduction)
- [Technologies](#Technologies)
- [Getting Started](#getting-started)
  - [Running Locally](#running-locally)
  - [Running Tests](#running-tests)
- [Available Routes](#available-routes)
- [Useful Links](#useful-links)  
  
## Introduction
**Potinho** is a back-end to simulate a bank, responsible to create users and carry out transactions

## Technologies
What was used:
- **[Docker](https://docs.docker.com)** and **[Docker Compose](https://docs.docker.com/compose/)** to create our development and test environments.
- **[github actions](https://github.com/features/actions)** for ~~deployment~~ and as general CI.
- **[Postgres](https://www.postgresql.org/)** to store the data and **[Ecto](https://hexdocs.pm/ecto/Ecto.html)** as a """ORM""" (but is not a ORM is a DSL).
- **[Ex_unit](https://hexdocs.pm/ex_unit/main/ExUnit.html)** to run tests.
- **[ASDF](https://asdf-vm.com/)** to manage multiple versions
- **[LiveBook]**() To easily create scripts of a business cycle

# Getting Started
To get started, you should install **Docker**, **Docker Compose**, and **ASDF**.
Then, clone the repository:
```sh
git clone https://github.com/romulogarofalo/Gastar.me.git
```
enter in the folder
```sh
cd potinho
```

run asdf to install elixir and erlang
```sh
asdf install
```

if the commnad above not work maybe you could need to add the elixir and erlang to asdf work **[more info here](https://github.com/asdf-vm/asdf-elixir)**
```sh
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git

```

You should run to download dependencies
```
mix deps.get
```
to install all the dependencies
## Running Locally
To run locally, simply run the following command:
```sh
docker-compose up
```
## Running Tests
To run the tests, run the following command:
```sh
mix test
```
## Running The Server
To run the tests, run the following command:
```sh
mix phx.server
```

## Running The Livebook
when docker-compose is up the Livebook will be up on [localhost:8080](localhost:8080) and to make the requests the server will need to be up on your computer (not the docker)

Password is `potinho-password`


# Available Routes

Rotas 

| Rotas                  | Descrição                                  | Metodos HTTP |
|------------------------|--------------------------------------------|--------------|
|/api/login              | login route and auth                       | POST         |
|/api/signup             | register of new user                       | POST         |
|/api/transaction        | create new transaction                     | POST         |
|/api/transaction        | get all transaction from user in a period  | GET          |
|/api/chargeback         | rollback a transaction if is possible      | POST         |
|/api/balance            | get the balance of the current user        | GET          |


## Useful Links
[Linter used](https://hex.pm/packages/credo) <br>
[commit pattern with emogis](https://gitmoji.dev/)