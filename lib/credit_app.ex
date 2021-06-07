defmodule CommandedTest.CreditApp do
  @moduledoc """
  Base commanded module for our architecture. Not expected to have much functionality.
  """
  # todo: do we want this in config?
  use Commanded.Application,
    otp_app: :commanded_test,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: CommandedTest.EventStore
    ]

  router CommandedTest.CreditRouter
end
