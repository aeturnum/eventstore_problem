defmodule CommandedTest.Credits.CreditAdjustmentOpened do
  @derive Jason.Encoder
  defstruct account_id: "",
            adjustment_id: "",
            adjustment: 0,
            reason: nil,
            timestamp: nil

  @type t :: %__MODULE__{
    account_id: binary(),
    adjustment_id: binary(),
    adjustment: integer(),
    reason: CommandedTest.Credits.Reasons.t(),
    timestamp: DateTime.t()
  }
end
