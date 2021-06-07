defmodule CommandedTest.Credits.InitAccount do
  @moduledoc """
  This is, for all intents and purposes, a setAccountBalance command that always has
  a value of 0 and a nil reason. We want this special-case event because we can apply
  it to all accounts without risking a state change (except for starting new accounts)
  at 0.
  """
  defstruct account_id: ""

  @type t :: %__MODULE__{
    account_id: binary()
  }
end
