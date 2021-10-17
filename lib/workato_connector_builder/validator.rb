module WorkatoConnectorBuilder
  class Validator
    def initialize(shell)
      @shell = shell
    end

    def process(node)
      validate_top_level_hash(node)
    end

    private

    def validate_top_level_hash(hash_node)
      valid_keys = WorkatoConnectorBuilder::Constants::TOP_LEVEL_KEYS
      process_hash(
        hash_node,
        valid_keys,
        :first
      )
    end

    def validate_first_child_level(pair)
      ancestor_keys = get_ancestor_keys(pair, include_self: true)
      first_level_keys = WorkatoConnectorBuilder::Constants::FIRST_CHILD_LEVEL_KEYS[ancestor_keys.first] || []

      processed_hash = process_hash(
        pair.value,
        first_level_keys,
        :second
      )

      unless processed_hash.nil?
        update_node(pair, children: [pair.key, processed_hash])
      end
    end

    def validate_second_child_level(pair)
      parent_keys = get_ancestor_keys(pair, include_self: true)
      # check the current hash, then check the root one, this covers :connection.authorization and :triggers for example
      second_level_keys = WorkatoConnectorBuilder::Constants::SECOND_CHILD_LEVEL_KEYS[parent_keys.last] ||
        WorkatoConnectorBuilder::Constants::SECOND_CHILD_LEVEL_KEYS[parent_keys.first] || []

      if second_level_keys.empty?
        update_node(pair, copy_children: true)
      end

      processed_hash = process_hash(
        pair.value,
        second_level_keys,
        nil
      )

      unless processed_hash.nil?
        pair.updated(:pair, [pair.key, processed_hash])
      end
    end

    def update_node(node, copy_children: false, children: nil)
      children = copy_children ? node.children : children
      if children.nil?
        nil
      else
        node.updated(node.type, children)
      end
    end

    def process_hash(hash_node, valid_hash_keys, next_level_func)
      kept_pairs = []
      kept_invalid_pairs = []
      hash_node.pairs.each do |pair|
        parent_keys = get_ancestor_keys(pair)
        message = "Error: '#{pair.key.value}' is not a valid key for "
        if parent_keys.nil? || parent_keys.empty?
          message << 'the root level'
        else
          parent_keys_label = parent_keys.join('.')
          message << "'#{parent_keys_label}'"
        end
        if !valid_hash_keys.empty? && !valid_hash_keys.include?(pair.key.value.to_s.to_sym)
          @shell.say "Error: #{message}", :red
          choice = @shell.ask(
            'Do you wish to keep the key => value in the final output?',
            :limited_to => %w[yes no]
          )
          # Only valid pairs need to have their children checked
          if choice == 'yes'
            # This will reset the sibling relationships
            kept_invalid_pairs << update_node(pair, copy_children: true)
          end

          next
        end

        if pair.value.hash_type? && !next_level_func.nil?
          processed_pair = self.send("validate_#{next_level_func}_child_level", pair)
          unless processed_pair.nil?
            kept_pairs << processed_pair
          end
        else
          # This will reset the sibling relationships
          kept_pairs << update_node(pair, copy_children: true)
        end
      end

      kept_pairs.sort_by! { |p| sort_by_valid_keys(p, valid_hash_keys) }

      kept_invalid_pairs.sort! { |a, b| a.key <=> b.key }

      hash_node.updated(:hash, kept_pairs.concat(kept_invalid_pairs))
    end

    def sort_by_valid_keys(p, keys)
      key = p.key.value.to_s.to_sym
      keys.index(key) || key
    end

    def get_ancestor_keys(pair, include_self: false)
      if pair.root?
        return []
      end

      keys = include_self ? [pair.key.value.to_s.to_sym] : []
      parent = pair.parent
      while parent != nil
        if parent.pair_type?
          keys << parent.key.value.to_s.to_sym
        end
        parent = parent.parent
      end

      keys.reverse!

      keys
    end
  end
end