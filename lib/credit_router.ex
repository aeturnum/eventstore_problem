defmodule CommandedTest.CreditRouter do
  @moduledoc """
  Router for credits on commanded, handles which aggregator module will deal with which command
  """
  use Commanded.Commands.Router
  alias CommandedTest.Credits

  identify Credits.AccountCredits, by: :account_id

  dispatch [
    Credits.InitAccount,
    Credits.SetAccountBalance,
    Credits.AdjustCredits,
    Credits.CloseCreditAdjustment,
    Credits.OpenCreditAdjustment
  ], to: Credits.AccountCredits

end
