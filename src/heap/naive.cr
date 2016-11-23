class Array(T)
  def heap_push(item)
    self << item
    sift_down(0, size - 1)
  end

  def heap_pop
    # Pop the smallest item off the heap, maintaining the heap invariant.
    lastelt = pop
    if size > 0
      returnitem = self[0]
      self[0] = lastelt
      sift_up(0)
      return returnitem
    end
    return lastelt
  end

  def heap_replace(item)
    # Pop and return the current smallest value, and add the new item.

    # This is more efficient than heappop() followed by heappush(), and can be
    # more appropriate when using a fixed-size heap.  Note that the value
    # returned may be larger than item!  That constrains reasonable uses of
    # this routine unless written as part of a conditional replacement:
    returnitem = self[0]
    self[0] = item
    sift_up(0)
    return returnitem
  end

  def heap_pushpop(item)
    # Fast version of a heappush followed by a heappop.
    if size > 0 && self[0] < item
      item, self[0] = self[0], item
      sift_up(0)
    end
    return item
  end

  def heapify!
    # Transform list into a heap, in-place, in O(len(x)) time.
    ((size/2 - 1)..0).each do |i|
      sift_up(i)
    end
    self
  end

  def heapify
    self.clone.heapify!
  end

  private def sift_down(start_pos, pos)
    newitem = self[pos]
    while pos > start_pos
      parent_pos = (pos - 1) >> 1
      parent = self[parent_pos]
      if newitem < parent
        self[pos] = parent
        pos = parent_pos
        next
      end
      break
    end
    self[pos] = newitem
  end

  private def sift_up(pos)
    end_pos = size
    start_pos = pos
    newitem = self[pos]
    child_pos = 2*pos + 1
    while child_pos < end_pos
      right_pos = child_pos + 1
      if right_pos < end_pos && self[child_pos] >= self[right_pos]
        child_pos = right_pos
      end
      self[pos] = self[child_pos]
      pos = child_pos
      child_pos = 2*pos + 1
    end
    self[pos] = newitem
    sift_down(start_pos, pos)
  end

  private def sift_down_max(start_pos, pos)
    newitem = self[pos]
    while pos > start_pos
      parent_pos = (pos - 1) >> 1
      parent = self[parent_pos]
      if parent < newitem
        self[pos] = parent
        pos = parent_pos
        next
      end
      break
    end
    self[pos] = newitem
  end

  private def sift_up_max(pos)
    end_pos = size
    start_pos = pos
    newitem = self[pos]
    child_pos = 2*pos + 1
    while child_pos < end_pos
      right_pos = child_pos + 1
      if right_pos < end_pos && self[right_pos] >= self[child_pos]
        child_pos = right_pos
      end
      self[pos] = self[child_pos]
      pos = child_pos
      child_pos = 2*pos + 1
    end
    self[pos] = newitem
    sift_down_max(start_pos, pos)
  end

  def heap_pop_max
    # Maxheap version of a heappop.
    lastelt = pop
    if size > 0
      returnitem = self[0]
      self[0] = lastelt
      sift_up_max(0)
      return returnitem
    end
    lastelt
  end

  def heap_replace_max(item)
    # Maxheap version of a heappop followed by a heappush.
    returnitem = self[0]
    self[0] = item
    sift_up_max(0)
    return returnitem
  end

  def heapify_max!
    # Transform list into a maxheap, in-place, in O(len(x)) time.
    ((size/2 - 1)..0).each do |i|
      sift_up_max(i)
    end
  end

  def self.merge(*iterables, &block : T -> _)
    heap = Array(Tuple(T, Int32, Int32)).new(iterables.size)
    iterables.each_with_index do |x, ith_array|
      if x.size > 0
        heap << ({x[0], ith_array, 1})
      end
    end
    heap.heapify!
    while heap.size >= 1
      elm, ith_array, ith_elm = heap[0]
      block.call(elm)
      if ith_elm < iterables[ith_array].size
        heap.heap_replace({iterables[ith_array][ith_elm], ith_array, ith_elm + 1})
      else
        heap.heap_pop
      end
    end
  end

  def self.merge_by(*iterables, key_func : T -> K, &block : T -> _)
    heap = Array(Tuple(K, T, Int32, Int32)).new(iterables.size)
    iterables.each_with_index do |x, ith_array|
      if x.size > 0
        heap << ({key_func.call(x[0]), x[0], ith_array, 1})
      end
    end
    heap.heapify!
    while heap.size >= 1
      _, elm, ith_array, ith_elm = heap[0]
      block.call(elm)
      if ith_elm < iterables[ith_array].size
        new_elem = iterables[ith_array][ith_elm]
        heap.heap_replace({key_func.call(new_elem), new_elem, ith_array, ith_elm + 1})
      else
        heap.heap_pop
      end
    end
  end

  def nlargest(n)
    if size <= n
      return self.clone
    end
    heap = Array(T).new n
    (0...n).each do |i|
      heap << self[i]
    end
    heap.heapify!
    top = heap[0]
    (n...size).each do |i|
      if top < self[i]
        top = self[i]
        heap.heap_replace(top)
      end
    end
    return heap
  end

  def nlargest_by(n, &key_func : T -> K)
    if size <= n
      return self.clone
    end
    heap = Array(Tuple(K, T)).new n
    (0...n).each do |i|
      heap << ({key_func.call(self[i]), self[i]})
    end
    heap.heapify!
    top_key, top = heap[0]
    (n...size).each do |i|
      elm_key = key_func.call(self[i])
      if top_key < elm_key
        top = self[i]
        top_key = elm_key
        heap.heap_replace({top_key, top})
      end
    end
    return heap.map { |k_v_tuple| k_v_tuple[1] }
  end

  def nsmallest(n)
    if size <= n
      return self.clone
    end
    heap = Array(T).new n
    (0...n).each do |i|
      heap << self[i]
    end
    heap.heapify_max!
    (n...size).each do |i|
      top = heap[0]
      if top > self[i]
        top = self[i]
        heap.heap_replace_max(top)
      end
    end
    return heap
  end

  def nsmallest_by(n, &key_func : T -> K) : Array(T)
    if size <= n
      return self.clone
    end
    heap = Array(Tuple(K, T)).new n
    (0...n).each do |i|
      heap << ({key_func.call(self[i]), self[i]})
    end
    heap.heapify_max!
    top_key, top = heap[0]
    (n...size).each do |i|
      elm_key = key_func.call(self[i])
      if top_key > elm_key
        top = self[i]
        top_key = elm_key
        heap.heap_replace_max({top_key, top})
      end
    end
    return heap.map { |k_v_tuple| k_v_tuple[1] }
  end
end
