defmodule CommandedTest.Credits.Reasons.Subscription do
  @derive Jason.Encoder
  defstruct label: :subscription,
            plan_id: ""

  @type label :: :subscription
  @type t :: %__MODULE__{
    label: label(),
    plan_id: binary()
  }
end

defmodule CommandedTest.Credits.Reasons.Announcement do
  @derive Jason.Encoder
  defstruct label: :announcement,
            announcement_id: ""

  @type label :: :announcement
  @type t :: %__MODULE__{
    label: label(),
    announcement_id: binary()
  }
end

defmodule CommandedTest.Credits.Reasons.Refund do
  @derive Jason.Encoder
  defstruct label: :refund,
            note: ""

  @type label :: :refund
  @type t :: %__MODULE__{
    label: label(),
    note: binary()
  }
end

defmodule CommandedTest.Credits.Reasons.CSAdjustment do
  @derive Jason.Encoder
  defstruct label: :cs_adjustment,
            adjusted_by: "",
            note: ""

  @type label :: :cs_adjustment
  @type t :: %__MODULE__{
    label: label(),
    adjusted_by: binary(),
    note: binary()
  }
end

defmodule CommandedTest.Credits.Reasons.Custom do
  @derive Jason.Encoder
  defstruct label: :custom,
            note: ""

  @type label :: :custom
  @type t :: %__MODULE__{
    label: label(),
    note: binary()
  }
end

defmodule CommandedTest.Credits.Reasons do
  @moduledoc """
  Intermediate module to allow different structures to sit in the same 'slot' of an event
  """
  alias CommandedTest.Credits.Reasons

  @type t :: Reasons.Subscription.t() |
             Reasons.Announcement.t() |
             Reasons.Refund.t() |
             Reasons.CSAdjustment.t() |
             Reasons.Custom.t() |
             nil

  @spec subscription(binary()) :: Reasons.Subscription.t()
  def subscription(plan_id), do: %Reasons.Subscription{plan_id: plan_id}

  @spec announcement(binary()) :: Reasons.Announcement.t()
  def announcement(announcement_id), do: %Reasons.Announcement{announcement_id: announcement_id}

  @spec refund(binary()) :: Reasons.Refund.t()
  def refund(note \\ ""), do: %Reasons.Refund{note: note}

  @spec cs_adjustment(binary(), binary()) :: Reasons.CSAdjustment.t()
  def cs_adjustment(adjusting_user, note \\ ""), do: %Reasons.CSAdjustment{adjusted_by: adjusting_user, note: note}

  @spec custom(binary()) :: Reasons.Custom.t()
  def custom(note), do: %Reasons.Custom{note: note}
end
