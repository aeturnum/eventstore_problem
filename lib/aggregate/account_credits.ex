defmodule CommandedTest.Credits.AccountCredits do
  @moduledoc """
  Keeps the number of record for credits.

  todo: need to figure out how many timestamps we want to keep. There are at least 4 that we might care about:
  1: timestamp for the precipitating request
  2: timestamp the command is created
  3: timestamp the event is created
  4: timestamp the event is applied

  right now we are just tracking 3.
  """
  alias CommandedTest.Credits
  alias Commanded.Aggregate.Multi
  alias CommandedTest.Credits.AccountCredits


  defstruct account_id: nil,
            balance: 0,
            open_adjustments: %{},
            history: []

  @type adj_record :: %{
    reason: Credits.Reasons.t(),
    adjustment: integer(),
    timestamp: DateTime.t()
  }

  @type snap_reason :: Credits.Reasons.t() | {Credits.Reasons.t(), Credits.Reasons.t()}

  @type snapshot :: %{
    reason: snap_reason(),
    change: integer(),
    balance: integer(),
    timestamp: DateTime.t()
  }

  @type t :: %__MODULE__{
    account_id: binary(),
    balance: integer(),
    open_adjustments: %{binary() => adj_record()},
    # order is timestamp descending (latest first, first last)
    history: list(snapshot)
  }

  @type command :: Credits.AdjustCredits.t() |
                   Credits.CloseCreditAdjustment.t() |
                   Credits.OpenCreditAdjustment.t() |
                   Credits.SetAccountBalance.t() |
                   Credits.InitAccount.t()

  @type event :: Credits.CreditsSetTo.t() |
                 Credits.CreditAdjustmentOpened.t() |
                 Credits.CreditAdjustmentClosed.t()

  @type error_atom :: :account_already_opened |
                      :account_not_opened |
                      :account_credits_not_set |
                      :must_open_adjustment_before_closing

  # Public command API

  # Init Account
  # Credits.InitAccount
  @spec execute(__MODULE__.t(), command()) :: event() | {:error, error_atom()}
  def execute(%AccountCredits{account_id: nil}, %Credits.InitAccount{account_id: acc_id}) do
    # initial creation event - will do nothing if account is opened
    %Credits.CreditsSetTo{account_id: acc_id, new_balance: 0, prev_balance: 0, reason: nil, timestamp: now()}
  end

  # reject all other events for an unopened account
  def execute(%AccountCredits{account_id: nil}, _), do: {:error, :account_not_opened}

  def execute(_, %Credits.InitAccount{}), do: {:error, :account_already_opened}

  # Set Account Balance
  # Credits.SetAccountBalance

  def execute(%AccountCredits{} = acc, %Credits.SetAccountBalance{} = set_credits) do
    # todo: may want this to be a multi-event that also closes all open transactions will full reversals
    %Credits.CreditsSetTo{
      account_id: set_credits.account_id,
      new_balance: set_credits.new_balance,
      prev_balance: acc.balance,
      reason: set_credits.reason,
      timestamp: now()
    }
  end

  # Adjust Account
  # Credits.CloseCreditAdjustment
  # Credits.OpenCreditAdjustment
  # Credits.AdjustCredits

  def execute(%AccountCredits{} = acc, %Credits.CloseCreditAdjustment{} = close_adj) do
    if Map.has_key?(acc.open_adjustments, close_adj.adjustment_id) do
      %Credits.CreditAdjustmentClosed{
        adjustment_id: close_adj.adjustment_id,
        close_change: close_adj.change_to_adjustment,
        reason: close_adj.reason
      }
    else
      {:error, :must_open_adjustment_before_closing}
    end
  end

  def execute(%AccountCredits{}, %Credits.OpenCreditAdjustment{} = open_adj) do
    %Credits.CreditAdjustmentOpened{
      account_id: open_adj.account_id,
      adjustment_id: UUID.uuid4(),
      adjustment: open_adj.adjustment,
      reason: open_adj.reason,
      timestamp: now()
    }
  end

  def execute(%AccountCredits{} = acc, %Credits.AdjustCredits{} = adj) do
    adj_id = UUID.uuid4()
    ts = now()

    Multi.new(acc)
    |> Multi.execute(fn _ ->
      %Credits.CreditAdjustmentOpened{
        account_id: adj.account_id,
        adjustment_id: adj_id,
        adjustment: adj.adjustment,
        reason: adj.reason,
        timestamp: ts
      }
    end)
    |> Multi.execute(fn _ -> %Credits.CreditAdjustmentClosed{adjustment_id: adj_id, timestamp: ts} end)
  end


  # State mutators
  @spec apply(__MODULE__.t(), event()) :: __MODULE__.t()
  def apply(%AccountCredits{} = account, %Credits.CreditsSetTo{} = event) do
    # todo: what to do about open adjustments? We probably keep them open

    %AccountCredits{account |
      # need to set the account_id because it will be nil initially
      account_id: event.account_id,
      balance: event.new_balance,
      history: [
        snapshot(
          event.new_balance,
          event.new_balance - account.balance,
          event.reason,
          event.timestamp
        ) | account.history
      ]
    }
  end

  def apply(%AccountCredits{} = account, %Credits.CreditAdjustmentOpened{} = event) do
    # todo: does opening an adjustment change history? I think not. The history gets changed
    # todo: when we close an adjustment.

    %AccountCredits{account |
      open_adjustments: Map.put(account.open_adjustments, event.adjustment_id, get_adj_map(event))
    }
  end

  def apply(%AccountCredits{} = account, %Credits.CreditAdjustmentClosed{} = event) do
    # The big one!
    # We actually change balance here.

    case find_adjustment(account, event.adjustment_id) do
      {:ok, open_adj, account_w_o_adj} ->
        close_adj = get_adj_map(event)

        account_w_o_adj
        |> update_balance(open_adj, close_adj)
        |> update_history(open_adj, close_adj)

      {:error, :not_found} ->
        # we cannot return an error here
        IO.puts("Could not find adjustment #{event.adjustment_id} in the list of open adjustments for account #{account.account_id}")
        account
    end
  end

  @spec find_adjustment(__MODULE__.t(), binary()) :: {:ok, adj_record(), __MODULE__.t()} | {:error, :not_found}
  defp find_adjustment(%AccountCredits{open_adjustments: o_adjs} = acct, id) do
    if Map.has_key?(o_adjs, id) do
      {:ok, o_adjs[id], %{acct | open_adjustments: Map.drop(o_adjs, [id])}}
    else
      {:error, :not_found}
    end
  end

  @spec update_balance(__MODULE__.t(), adj_record(), adj_record()) :: __MODULE__.t()
  defp update_balance(acct, o_adj, c_adj), do: %{acct | balance: acct.balance + combined_change(o_adj, c_adj)}

  @spec update_history(__MODULE__.t(), adj_record(), adj_record()) :: __MODULE__.t()
  defp update_history(updated_acct, o_adj, c_adj) do
    snap = case {o_adj.reason, c_adj.reason} do
      {r1, nil} -> snapshot(updated_acct.balance, combined_change(o_adj, c_adj), r1, c_adj.timestamp)
      {r1, r2} -> snapshot(updated_acct.balance, combined_change(o_adj, c_adj), {r1, r2}, c_adj.timestamp)
    end

    # todo: sync changes on chargify side

    %{updated_acct | history: [snap | updated_acct.history]}
  end

  @spec snapshot(integer(), integer(), snap_reason(), DateTime.t()) :: snapshot()
  defp snapshot(balance, change, reasons, ts), do: %{reason: reasons, change: change, balance: balance, timestamp: ts}

  @spec combined_change(adj_record(), adj_record()) :: integer()
  defp combined_change(o_adj, c_adj), do: o_adj.adjustment + c_adj.adjustment

  @spec get_adj_map(Credits.CreditAdjustmentOpened.t() | Credits.CreditAdjustmentClosed.t()) :: adj_record()
  defp get_adj_map(%{adjustment: a, reason: r, timestamp: ts}), do: %{adjustment: a, reason: r, timestamp: ts}
  defp get_adj_map(%{close_change: a, reason: r, timestamp: ts}), do: %{adjustment: a, reason: r, timestamp: ts}

  @spec now() :: DateTime.t()
  defp now(), do: DateTime.utc_now()
end
