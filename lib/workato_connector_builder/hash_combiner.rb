module WorkatoConnectorBuilder
  class HashCombiner
    def initialize(shell)
      @shell = shell
    end

    def combine(first, second)
      if !first.hash_type? or !second.hash_type?
        return
      end

      concat_pairs = []
      first.pairs.each do |pair|
        matching_pair = second.pairs.find { |sp| sp.key == pair.key }
        if matching_pair.nil?
          concat_pairs.push pair
        else
          if pair.value.hash_type? && matching_pair.value.hash_type?
            combined_node = combine(pair.value, matching_pair.value)
            concat_pairs.push pair.updated(:pair, [pair.key].push(combined_node))
          else
            chosen_pair = replace_pair pair, matching_pair

            unless chosen_pair.nil?
              concat_pairs.push chosen_pair.updated(:pair, chosen_pair.children)
            end
          end
        end
      end

      concat_pairs.concat(second.pairs.select { |pair| !first.keys.include? pair.key } || [])

      first.updated(:hash, concat_pairs)
    end

    private

    attr_reader :shell

    def replace_pair(first, second)
      source = first

      @shell.say_status(
        "Error: Mismatch found for key '#{first.key.value}'",
        "Occurs at '#{first.source_range.to_s}' and '#{second.source_range.to_s}'",
        :red
      )

      choice = @shell.ask(
        %{Select a choice:
  1) #{first.source}
  2) #{second.source}
  3) Do not include key\n},
        :limited_to => %w[1 2 3]
      )

      case choice
      when '2'
        source = second
      when '3'
        source = nil
      end

      source
    end

    def get_pair_source(pair, include_comma = false, remove_leading_newlines = false, rstrip = false)
      parent_source = pair.parent.source
      parent_source_range = pair.parent.source_range

      # Let's get any formatting that was in place from the second node
      # Assume we're starting at the first pair, so we'll make our start position
      # after the opening { and the end pos is after the }
      pair_begin_pos = 1
      pair_end_pos = parent_source.length - 2
      # We need to get the position in relation to the parent's source range,
      # since we're not using any parents ancestors when getting this source
      pair_left_sibling = pair.left_sibling
      unless pair_left_sibling.nil?
        # Start after the left sibling's comma
        pair_begin_pos = pair_left_sibling.source_range.end_pos + 1 - parent_source_range.begin_pos
      end

      # If we have a right sibling, we'll get to the start of it so we can capture any
      # comments
      pair_right_sibling = pair.right_sibling
      unless pair_right_sibling.nil?
        pair_end_pos = pair_right_sibling.source_range.begin_pos - 1 - parent_source_range.begin_pos
      end

      range = Range.new pair_begin_pos, pair_end_pos
      pair_source = parent_source[range]

      # trim off any newlines at the start, since we'll be inserting
      # this into the other hash which might have it's own ending whitespace
      if remove_leading_newlines
        pair_source.sub!(/^[\n\r]*/, '')
      end

      if rstrip
        pair_source.rstrip!
      end

      if include_comma
        unless pair_source.rstrip.end_with?(',')
          pair_source[pair.source] = "#{pair.source},"
        end
      else
        pair_source[pair_source.rindex(',')] = ''
      end

      pair_source
    end
  end
end