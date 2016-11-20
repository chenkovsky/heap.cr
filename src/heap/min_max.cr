struct MinMaxHeap(T)
  include Enumerable(T)

  # example of min max heap
  #          8
  #         /  \
  #        71   41
  #      / \    / \
  #     31 10  11  16
  #   /\  / \   |
  # 46 51 34 21 13
  @comparator : (T, T -> Int32)?
  @max_size : Int32?
  @elems : Array(T)

  # if max_size is setted, when the heap size bigger than given size,
  # the last element will be poped out.
  def initialize(initial_capacity : Int32? = nil, @max_size : Int32? = nil)
    if initial_capacity.nil?
      @elems = Array(T).new
    else
      @elems = Array(T).new(initial_capacity: initial_capacity)
    end
  end

  def initialize(initial_capacity : Int32? = nil, @max_size : Int32? = nil, &block : T, T -> Int32)
    @comparator = block
    if initial_capacity.nil?
      @elems = Array(T).new
    else
      @elems = Array(T).new(initial_capacity: initial_capacity)
    end
  end

  def initialize(enumerable : Enumerable(T), @max_size : Int32? = nil, &block : T, T -> Int32)
    @comparator = block
    if @max_size.nil?
      @elems = Array(T).new
    else
      @elems = Array(T).new(initial_capacity: @max_size.as(Int32))
    end
    enumerable.each do |e|
      push e
    end
  end

  def initialize(enumerable : Enumerable(T), @max_size : Int32? = nil)
    if @max_size.nil?
      @elems = Array(T).new
    else
      @elems = Array(T).new(initial_capacity: @max_size.as(Int32))
    end
    enumerable.each do |e|
      push e
    end
  end

  def <<(elem)
    push elem
  end

  def peek
    assert_not_empty
    @elems[0]
  end

  def peek_first
    peek
  end

  def peek_last
    assert_not_empty
    @elems[max_elem_index]
  end

  def max_elem_index
    case @elems.size
    when 1
      0
    when 2
      1
    else
      compare_elem(@elems[1], @elems[2]) <= 0 ? 2 : 1
    end
  end

  def pop_first
    pop
  end

  private def assert_not_empty
    raise Exception.new "heap is empty" if @elems.size == 0
  end

  def pop
    assert_not_empty
    return remove_and_get(0)
  end

  def pop_last
    assert_not_empty
    return remove_and_get(max_elem_index)
  end

  private def remove_and_get(index : Int32)
    val = @elems[index]
    remove_at(index)
    return val
  end

  private def remove_at(index : Int32)
    raise Exception.new "index: #{index} >= elems.size :#{@elems.size}" if index >= @elems.size
    @elems[index] = @elems[-1]
    @elems.pop
    if index == @elems.size
      return
    end
    sift_down(index)
  end

  private def left_child(idx : Int32)
    (idx << 1) + 1
  end
  private def right_child(idx : Int32)
    (idx << 1) + 2
  end
  private def parent(idx : Int32)
    return -1 if idx == 0
    (idx - 1) >> 1
  end
  private def grand_parent(idx : Int32)
    p = parent(idx)
    return -1 if p <= 0
    return parent(p)
  end

  private enum HeapLevel
    MinLevel
    MaxLevel
  end

  private EVEN_POWERS_OF_TWO = 0x55555555
  private ODD_POWERS_OF_TWO = 0xaaaaaaaa

  private def is_even_level(idx : Int32)
    onebased = idx + 1
    (onebased & EVEN_POWERS_OF_TWO) > (onebased & ODD_POWERS_OF_TWO)
  end

  private def level_for_index(idx : Int32) : HeapLevel
    is_even_level(idx) ? HeapLevel::MinLevel : HeapLevel::MaxLevel
  end

  private def swap(idx1 : Int32, idx2 : Int32)
    tmp = @elems[idx1]
    @elems[idx1] = @elems[idx2]
    @elems[idx2] = tmp
  end

  private def compare_elem(elem1 : T, elem2 : T)
    comparator = @comparator
    if comparator.nil?
      elem1 <=> elem2
    else
      comparator.call(elem1, elem2)
    end
  end

  private def sift_up(idx : Int32)
    parent_idx = parent(idx)
    return if parent_idx < 0
    cmp = compare_elem(@elems[parent_idx], @elems[idx])
    return if cmp == 0
    case level_for_index(idx)
    when HeapLevel::MinLevel
      if cmp < 0
        swap(parent_idx, idx)
        sift_up_max(parent_idx)
      else
        sift_up_min(idx)
      end
    when HeapLevel::MaxLevel
      if cmp > 0
        swap(parent_idx, idx)
        sift_up_min(parent_idx)
      else
        sift_up_max(idx)
      end
    end
  end

  private def sift_up_max(idx)
    grand_parent_idx = grand_parent(idx)
    while grand_parent_idx >= 0
      cmp = compare_elem(@elems[grand_parent_idx], @elems[idx])
      break if cmp >= 0
      swap(idx, grand_parent_idx)
      idx = grand_parent_idx
      grand_parent_idx = grand_parent(idx)
    end
  end
  private def sift_up_min(idx)
    grand_parent_idx = grand_parent(idx)
    while grand_parent_idx >= 0
      cmp = compare_elem(@elems[grand_parent_idx], @elems[idx])
      break if cmp <= 0
      swap(idx, grand_parent_idx)
      idx = grand_parent_idx
      grand_parent_idx = grand_parent(idx)
    end
  end

  private def sift_down(idx)
    case level_for_index(idx)
    when HeapLevel::MinLevel
      sift_down_min(idx)
    else
      sift_down_max(idx)
    end
  end

  private def is_grand(parent, child)
    right_child(parent) < child
  end
  private def sift_down_min(idx)
    loop {
      min = min_children_and_grand_children(idx)
      return if min < 0 # no child
      if is_grand(idx, min)
        if compare_elem(@elems[min], @elems[idx]) < 0
          swap(min, idx)
          p_idx = parent(min)
          if compare_elem(@elems[min], @elems[p_idx]) > 0
            swap(min, p_idx)
          end
          idx = min
          next
        end
      else
        if compare_elem(@elems[min], @elems[idx]) < 0
          swap(min, idx)
        end
      end
      break
    }
  end
  private def sift_down_max(idx)
    loop {
      max = max_children_and_grand_children(idx)
      return if max < 0 # no child
      if is_grand(idx, max)
        if compare_elem(@elems[max], @elems[idx]) > 0
          swap(max, idx)
          p_idx = parent(max)
          if compare_elem(@elems[max], @elems[p_idx]) < 0
            swap(max, p_idx)
          end
          idx = max
          next
        end
      else
        if compare_elem(@elems[max], @elems[idx]) > 0
          swap(max, idx)
        end
      end
      break
    }
  end

  private def min_children_and_grand_children(idx)
    ret = -1
    children_and_grand_children(idx) do |cidx|
      ret = cidx if ret < 0 || compare_elem(@elems[cidx], @elems[ret]) < 0
    end
    return ret
  end

  private def max_children_and_grand_children(idx)
    ret = -1
    children_and_grand_children(idx) do |cidx|
      ret = cidx if ret < 0 || compare_elem(@elems[cidx], @elems[ret]) > 0
    end
    return ret
  end

  private def children(idx)
    elem_num = @elems.size
    lchild_idx = left_child(idx)
    if lchild_idx < elem_num
      yield lchild_idx
    else
      return
    end
    rchild_idx = right_child(idx)
    if rchild_idx < elem_num
      yield rchild_idx
    else
      return
    end
  end

  private def children_and_grand_children(idx)
    children(idx) do |child_idx|
      yield child_idx
      children(child_idx) do |grand_child_idx|
        yield grand_child_idx
      end
    end
  end

  private def grand_children(idx)
    children(idx) do |child_idx|
      children(child_idx) do |grand_child_idx|
        yield grand_child_idx
      end
    end
  end

  def push(elem : T)
    idx = @elems.size
    @elems << elem
    sift_up(idx)
    max_size = @max_size
    if !max_size.nil? && @elems.size > max_size
      pop_last
    end
  end

  delegate :to_s, to: @elems
  delegate :to_json, to: @elems

  delegate :size, to: @elems
  delegate :each, to: @elems
end
