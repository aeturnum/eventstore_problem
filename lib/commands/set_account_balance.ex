defmodule CommandedTest.Credits.SetAccountBalance do
  defstruct account_id: "",
            new_balance: 0,
            reason: nil

  @type t :: %__MODULE__{
    account_id: binary(),
    new_balance: integer(),
    reason: CommandedTest.Credits.Reasons.t()
  }
end
