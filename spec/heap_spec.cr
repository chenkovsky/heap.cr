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
    Array(Int32).merge_by([3, 2, 1], [6, 5, 4], key_func: ->(x : Int32) { -x }) do |x|
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

  it "min_max_heap" do
    heap = MinMaxHeap(Int32).new
    heap << 1
    heap << 90
    heap << 100
    STDERR.puts heap.to_a
    arr = [1, 90, 100, 4, 8, 3, 2, 85, 40, 55, 70, 75, 60, 50, 10, 80]
    heap = MinMaxHeap(Int32).new arr
    heap.pop_last.should eq(100)
    heap.pop_last.should eq(90)
    heap << 100
    heap << 90
    arr2 = [] of Int32
    while heap.size > 0
      arr2 << (heap.pop)
    end
    arr2.should eq(arr.sort)
    heap = MinMaxHeap.new arr, max_size: 4
    arr2 = [] of Int32
    while heap.size > 0
      arr2 << (heap.pop)
    end
    arr2.should eq([1, 2, 3, 4])
  end
end
