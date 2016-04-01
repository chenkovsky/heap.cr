require "./spec_helper"

describe Heap do
  # TODO: Write tests

  it "nsmallest" do
    [1, 2, 3].nsmallest(2).sort.should eq([1, 2])
  end

  it "nsmallest_by" do
    [1, 2, 3].nsmallest_by(2) { |x| -x }.sort.should eq([2, 3])
  end

  it "merge" do
    res = [] of Int32
    Array(Int32).merge([1, 2, 3], [4, 5, 6]) do |x|
      res << x
    end
    res.should eq([1, 2, 3, 4, 5, 6])
  end

  it "mergeby" do
    res = [] of Int32
    Array(Int32).merge_by([3, 2, 1], [6, 5, 4], key_func = ->(x : Int32) { -x }) do |x|
      res << x
    end
    res.should eq([6, 5, 4, 3, 2, 1])
  end

  it "nlargest" do
    [1, 2, 3].nlargest(2).sort.should eq([2, 3])
  end

  it "nlargest_by" do
    [1, 2, 3, 4].nlargest_by(2) { |x| -x }.sort.should eq([1, 2])
  end

  it "push pop" do
    a = [1, 2]
    a.heap_push 3
    a.heap_pop.should eq(1)
  end

  it "heapify" do
    a = [3, 2, 1]
    a.heapify.should eq([1, 2, 3])
  end
end
