defmodule CommandedTest.Credits.AdjustCredits do
  defstruct account_id: "",
            adjustment: 0,
            reason: nil

  @type t :: %__MODULE__{
    account_id: binary(),
    adjustment: integer(),
    reason: CommandedTest.Credits.Reasons.t()
  }
end
