defmodule CommandedTest.CustomerListTest do
  use ExUnit.Case
  import Commanded.Assertions.EventAssertions

  alias CommandedTest.Credits
  alias CommandedTest.CreditApp

  # setup do
  #   account = insert(:account)

  #   %{
  #     account: account
  #   }
  # end

  test "Open Account" do
    :ok = CreditApp.dispatch(%Credits.InitAccount{account_id: "test id"})

    assert_receive_event(CommandedTest.CreditApp, Credits.CreditsSetTo, fn event ->
      assert event.id == 4
    end)
  end

end
