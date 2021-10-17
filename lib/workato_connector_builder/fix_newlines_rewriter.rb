require 'parser'

module WorkatoConnectorBuilder
  class FixNewlinesRewriter < Parser::TreeRewriter

    def on_pair(node)
      range = node.source_range
      add_trailing_comma(range, range.source.length)
      super
    end

    private

    def add_trailing_comma(range, source_length)
      unless has_trailing_comma?(range, source_length)
        insert_after range.end, ','
      end
    end

    def remove_trailing_comma(range, source_length)
      if has_trailing_comma?(range, source_length)
        remove range.adjust(begin_pos: source_length, end_pos: 1)
      end
    end

    def has_trailing_comma?(range, source_length)
      next_char_range = range.adjust(begin_pos: source_length, end_pos: 1)
      next_char_range.is?(',')
    end
  end
end