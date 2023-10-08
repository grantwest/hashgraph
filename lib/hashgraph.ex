defmodule Hashgraph do

  defstruct [
    :events,
    :shareholders,
    :total_shares,
  ]

  defmodule Event do
    @enforce_keys [:id, :creator]
    defstruct [
      :id,
      :creator,
      self_parent: :none,
      other_parent: :none,
      round: :notset,
      is_witness: :notset,
      is_famous: false,
    ]
  end

  defmodule Shareholder do
    @enforce_keys [:id, :shares]
    defstruct [
      :id,
      :shares,
    ]
  end

  def new(initial_shareholders) do
    total_shares = 
    Enum.map(initial_shareholders, fn s -> s.shares end)
    |> Enum.sum()

    %Hashgraph{
      events: %{},
      shareholders: Map.new(initial_shareholders, fn s -> {s.id, s} end),
      total_shares: total_shares,
    }
  end

  def round(event_id, hg) do
    hg.events[event_id].round
  end

  def is_witness(event_id, hg) do
    hg.events[event_id].is_witness
  end

  def is_famous(event_id, hg) do
    hg.events[event_id].is_famous
  end

  def add_event(hg, event) do
    r = max_round_of_parents(hg, event)
    r = if strongly_see_witnesses_in_round(event, r, hg), do: r + 1, else: r
    witness = event.self_parent == :none or r > hg.events[event.self_parent].round
    event = %{event | round: r, is_witness: witness}

    %{hg | events: Map.put(hg.events, event.id, event)}
  end

  def decide_fame(hg) do
    witnesses_by_round = 
    Map.values(hg.events)
    |> Enum.filter(fn e -> e.is_witness == true end)
    |> Enum.sort_by(&(&1.round))
    |> Enum.to_list()

    permutations(witnesses_by_round)
    |> Enum.filter(fn {x, y} -> y.round > x.round end)
    |> Enum.reduce({}, fn {x, y}, {} ->
      d = y.round - x.round
      s = witnesses_by_round
          |> Enum.filter(fn e -> e.round == y.round - 1  and strongly_sees?(y, e, hg) end)
          |> Enum.to_list()
      vote_counter = y
      voters = s
      
      yes_votes = s
          |> Enum.filter(fn e -> sees?(y, x, hg) end)
          |> Enum.map(fn e -> hg.shareholders[e.creator].shares end)
          |> Enum.sum()
      no_votes = hg.total_shares - yes_votes
      v = yes_votes >= no_votes
      t = if v, do: yes_votes, else: no_votes

    end)
    hg
  end

  defp permutations(list) do
    Enum.flat_map(list, fn x -> Enum.map(list, fn y -> {x, y} end) end)
  end

  defp max_round_of_parents(hg, event) do
    case {event.self_parent, event.other_parent} do
      {:none, :none} -> 1
      {p, :none} -> hg.events[p].round
      {:none, p} -> hg.events[p].round
      {p1, p2} -> max(hg.events[p1].round, hg.events[p2].round)
    end
  end

  defp strongly_see_witnesses_in_round(event, r, hg) do
    strongly_see_shares = 
    Map.values(hg.events)
    |> Enum.filter(fn e -> e.round == r and e.is_witness and strongly_sees?(event, e, hg) end)
    |> Enum.map(fn e -> hg.shareholders[e.creator].shares end)
    |> Enum.sum()

    strongly_see_shares > 2 * hg.total_shares / 3
  end


  # can x see y
  # TODO: should be false if contains fork
  def sees?(x, y, hg) do
    x.id == y.id
    or (x.self_parent != :none and sees?(hg.events[x.self_parent], y, hg)) 
    or (x.other_parent != :none and sees?(hg.events[x.other_parent], y, hg))
  end

  # can x strongly see y
  def strongly_sees?(x, y, hg) do
    seeing_shares = 
    Map.values(hg.events)
    |> Enum.filter(fn e -> sees?(x, e, hg) and sees?(e, y, hg) end)
    |> Enum.uniq_by(fn e -> e.creator end)
    |> Enum.map(fn e -> hg.shareholders[e.creator].shares end)
    |> Enum.sum()

    seeing_shares > 2 * hg.total_shares / 3 
  end

end
