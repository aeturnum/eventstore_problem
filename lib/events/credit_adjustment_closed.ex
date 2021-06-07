defmodule CommandedTest.Credits.CreditAdjustmentClosed do
  @derive Jason.Encoder
  defstruct adjustment_id: "",
            close_change: 0,
            reason: nil,
            timestamp: nil

  @type t :: %__MODULE__{
    adjustment_id: binary(),
    close_change: integer() | :undo,
    reason: CommandedTest.Credits.Reasons.t(),
    timestamp: DateTime.t()
  }
end
