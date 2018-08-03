class Array(T)
  {% for arg, idx in [:min, :max] %}
    private def sift_up{{(arg == :min ? "" : "_max").id}}(pos)
      end_pos = size
      start_pos = pos
      newitem = self[pos]
      child_pos = 2*pos + 1
      while child_pos < end_pos
        right_pos = child_pos + 1
        if right_pos < end_pos && self[child_pos] {{(arg == :min ? ">=" : "<").id}} self[right_pos]
          child_pos = right_pos
        end
        self[pos] = self[child_pos]
        pos = child_pos
        child_pos = 2*pos + 1
      end
      self[pos] = newitem
      sift_down{{(arg == :min ? "" : "_max").id}}(start_pos, pos)
    end

    private def sift_down{{(arg == :min ? "" : "_max").id}}(start_pos, pos)
      newitem = self[pos]
      while pos > start_pos
        parent_pos = (pos - 1) >> 1
        parent = self[parent_pos]
        if newitem {{(arg == :min ? "<" : ">").id}} parent
          self[pos] = parent
          pos = parent_pos
          next
        end
        break
      end
      self[pos] = newitem
    end

    def heap_pop{{(arg == :min ? "" : "_max").id}}
      # Pop the smallest item off the heap, maintaining the heap invariant.
      lastelt = pop
      if size > 0
        returnitem = self[0]
        self[0] = lastelt
        sift_up{{(arg == :min ? "" : "_max").id}}(0)
        return returnitem
      end
      lastelt
    end

    def heap_replace{{(arg == :min ? "" : "_max").id}}(item)
      # Pop and return the current smallest value, and add the new item.
      # This is more efficient than heappop() followed by heappush(), and can be
      # more appropriate when using a fixed-size heap.  Note that the value
      # returned may be larger than item!  That constrains reasonable uses of
      # this routine unless written as part of a conditional replacement:
      returnitem = self[0]
      self[0] = item
      sift_up{{(arg == :min ? "" : "_max").id}}(0)
      return returnitem
    end

    def heapify{{(arg == :min ? "" : "_max").id}}!
      # Transform list into a heap, in-place, in O(len(x)) time.
      ((size/2 - 1)..0).each do |i|
        sift_up{{(arg == :min ? "" : "_max").id}}(i)
      end
      self
    end

    def heap_push{{(arg == :min ? "" : "_max").id}}(item)
      self << item
      sift_down{{(arg == :min ? "" : "_max").id}}(0, size - 1)
    end

    def heap_pushpop{{(arg == :min ? "" : "_max").id}}(item)
      # Fast version of a heappush followed by a heappop.
      if size > 0 && self[0] < item
        item, self[0] = self[0], item
        sift_up{{(arg == :min ? "" : "_max").id}}(0)
      end
      return item
    end

    def heapify{{(arg == :min ? "" : "_max").id}}
      self.clone.heapify{{(arg == :min ? "" : "_max").id}}!
    end


    def n{{(arg == :min ? "largest" : "smallest").id}}(n, heap : Array(T)? = nil)
      if size <= n
        return self.clone
      end
      heap = Array(T).new n if heap.nil?
      (0...n).each do |i|
        heap << self[i]
      end
      heap.heapify{{(arg == :min ? "" : "_max").id}}!
      top = heap[0]
      (n...size).each do |i|
        if top {{(arg == :min ? "<" : ">").id}} self[i]
          top = self[i]
          heap.heap_replace{{(arg == :min ? "" : "_max").id}}(top)
        end
      end
      return heap
    end

    def n{{(arg == :min ? "largest" : "smallest").id}}_by(n, heap : Array(Tuple(K, T))? = nil, &key_func : T -> K) forall K
      if size <= n
        return self.clone
      end
      heap = Array(Tuple(K, T)).new n if heap.nil?
      (0...n).each do |i|
        heap << ({key_func.call(self[i]), self[i]})
      end
      heap.heapify{{(arg == :min ? "" : "_max").id}}!
      top_key, top = heap[0]
      (n...size).each do |i|
        elm_key = key_func.call(self[i])
        if top_key {{(arg == :min ? "<" : ">").id}} elm_key
          top = self[i]
          top_key = elm_key
          heap.heap_replace{{(arg == :min ? "" : "_max").id}}({top_key, top})
        end
      end
      return heap.map { |k_v_tuple| k_v_tuple[1] }
    end

    def arg_n{{(arg == :min ? "largest" : "smallest").id}}(n, heap : Array(Tuple(T, Int32))? = nil)
      if size <= n
        return self.clone
      end
      heap = Array(Tuple(T, Int32)).new n if heap.nil?
      (0...n).each do |i|
        heap << ({self[i], i})
      end
      heap.heapify{{(arg == :min ? "" : "_max").id}}!
      top, top_idx = heap[0]
      (n...size).each do |i|
        if top {{(arg == :min ? "<" : ">").id}} self[i]
          top = self[i]
          heap.heap_replace{{(arg == :min ? "" : "_max").id}}({top, i})
        end
      end
      return heap.map{|k_v_tuple| k_v_tuple[1]}
    end

    def arg_n{{(arg == :min ? "largest" : "smallest").id}}_by(n, heap : Array(Tuple(K, Int32))? = nil, &key_func : T -> K) forall K
      if size <= n
        return self.clone
      end
      heap = Array(Tuple(K, T)).new n if heap.nil?
      (0...n).each do |i|
        heap << ({key_func.call(self[i]), i})
      end
      heap.heapify{{(arg == :min ? "" : "_max").id}}!
      top_key, top_idx = heap[0]
      (n...size).each do |i|
        elm_key = key_func.call(self[i])
        if top_key {{(arg == :min ? "<" : ">").id}} elm_key
          top_key = elm_key
          heap.heap_replace{{(arg == :min ? "" : "_max").id}}({elm_key, i})
        end
      end
      return heap.map { |k_v_tuple| k_v_tuple[1] }
    end
  {% end %}

  def self.merge(*iterables, heap : Array(Tuple(T, Int32, Int32))? = nil, &block : T -> _)
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

  def self.merge_by(*iterables, key_func : T -> K, heap : Array(Tuple(K, T, Int32, Int32))? = nil, &block : T -> _) forall K
    heap = Array(Tuple(K, T, Int32, Int32)).new(iterables.size) if heap.nil?
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
end
