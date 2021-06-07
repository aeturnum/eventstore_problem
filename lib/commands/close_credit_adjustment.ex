defmodule CommandedTest.Credits.CloseCreditAdjustment do
  # account_id is only required in order to route the adjustment
  defstruct account_id: "",
            adjustment_id: "",
            change_to_adjustment: 0,
            reason: nil

  @type t :: %__MODULE__{
    account_id: binary(),
    adjustment_id: binary(),
    change_to_adjustment: integer() | :undo,
    reason: CommandedTest.Credits.Reasons.t()
  }
end
