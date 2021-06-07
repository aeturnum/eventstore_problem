defmodule CommandedTest.EventStore do
  @moduledoc """
  A part of the commanded ecosystem. This module must be configured to access postgres
  and also be setup to serialize Events.
  """
  use EventStore, otp_app: :commanded_test
end
