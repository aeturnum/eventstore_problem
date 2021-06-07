defmodule CommandedTest.Credits.CreditsSetTo do
  @derive Jason.Encoder
  defstruct account_id: "",
            new_balance: 0,
            prev_balance: 0,
            reason: nil,
            timestamp: nil

  @type t :: %__MODULE__{
    account_id: binary(),
    new_balance: integer(),
    prev_balance: integer(),
    reason: CommandedTest.Credits.Reasons.t(),
    timestamp: DateTime.t()
  }
end
