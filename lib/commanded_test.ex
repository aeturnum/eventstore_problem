defmodule CommandedTest do
  use Application

  def start(_type, _args) do
    Supervisor.start_link([{CommandedTest.CreditApp, []}], [strategy: :one_for_one, name: CommandedTest.Supervisor])
  end
end
