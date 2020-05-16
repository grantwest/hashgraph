defmodule HashgraphTest do
  use ExUnit.Case
  alias Hashgraph.Shareholder
  alias Hashgraph.Event

  describe "initilizing hashgraph" do
    test "contains no events" do
      hg = Hashgraph.new([%Shareholder{id: :me, shares: 100}])
      assert hg.events == %{}
    end
  end

  describe "adding events" do
    test "fails if self parent does not exist" do
      
    end

    test "fails if other parent does not exist" do
      
    end

    test "fails if creator is not shareholder" do
      
    end
  end


  describe "round and witness assignment" do
    test "first event" do
      shareholders = [%Shareholder{id: :me, shares: 100}]
      x = %Event{id: 0, creator: :me}
      hg = 
      Hashgraph.new(shareholders)
      |> Hashgraph.add_event(x)

      assert Hashgraph.round(x.id, hg) == 1
      assert Hashgraph.is_witness(x.id, hg) == true
    end

    test "simplest multi-round example" do
      shareholders = [%Shareholder{id: :me, shares: 100}]
      x0 = %Event{id: 0, creator: :me}
      x1 = %Event{id: 1, creator: :me, self_parent: 0}
      hg = 
      Hashgraph.new(shareholders)
      |> Hashgraph.add_event(x0)
      |> Hashgraph.add_event(x1)
      assert Hashgraph.round(0, hg) == 1
      assert Hashgraph.round(1, hg) == 2
      assert Hashgraph.is_witness(0, hg) == true
      assert Hashgraph.is_witness(1, hg) == true
    end
  end

  describe "deciding fame" do
    test "" do
      
    end
  end

  describe "sees" do
    test "cannot see if there was a fork" do
      
    end
  end

  describe "strongly_sees" do
    test "Figure 3 (a) from whitepaper" do

    end
  end

end
