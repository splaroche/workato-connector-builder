require_relative '../ast_generator'
require_relative '../hash_combiner'
require_relative '../constants'
require_relative '../validator'
require_relative '../fix_newlines_rewriter'

require 'parser/ruby24'
require 'rubocop-ast'

module WorkatoConnectorBuilder
  module CLI
    class BuildCommand

      def initialize(shell, source_path, output_file, ignored_files, ignored_dirs)
        @shell = shell
        @source_path = source_path
        @output_file = output_file
        @ignored_files = ignored_files
        @ignored_dirs = ignored_dirs
      end

      def exec
        unless @ignored_files.empty?
          @shell.say "Ignoring files:\n"
          @ignored_files.each do |f|
            @shell.say "\t#{f}\n"
          end
        end
        unless @ignored_dirs.empty?
          @shell.say "Ignoring directories:\n"
          @ignored_dirs.each do |f|
            @shell.say "\t#{f}\n"
          end
        end

        ast_generator = ASTGenerator.new(
          @source_path,
          create_parser,
          @ignored_dirs,
          @ignored_files,
        )

        hash_combiner = HashCombiner.new @shell
        output = process ast_generator, hash_combiner

        output_file = File.absolute_path(@output_file)

        @shell.say "Writing output file to : #{output_file}\n"
        File.open(output_file, 'w') do |file|
          file.write output
        end

        @shell.say "Done\n"
      end

      private

      attr_reader :shell, :ignored_files, :ignored_dirs, :output_file, :source_path

      def create_parser
        builder = RuboCop::AST::Builder.new
        Parser::Ruby24.new builder
      end

      def create_buffer(file_name, source)
        Parser::Source::Buffer.new file_name, **{ source: source }
      end

      def process(ast_generator, hash_combiner)
        asts = ast_generator.get_asts

        first_node = asts.first
        tree_rewriter = WorkatoConnectorBuilder::FixNewlinesRewriter.new

        asts.drop(1).each do |node|
          combined = hash_combiner.combine(first_node[:ast], node[:ast])
          first_node[:ast] = combined
        end

        # Check for valid workato keys
        validator = WorkatoConnectorBuilder::Validator.new(@shell)
        final_node = validator.process(first_node[:ast])

        output = write_hash(final_node, 0, 1)
        buffer = create_buffer(@output_file, output)
        parser = create_parser
        tree_rewriter.rewrite(buffer, parser.parse(buffer))

      end

      def write_hash(hash_node, indent_level, child_indent_level)
        indent = indent_string(indent_level)
        child_indent = indent_string(child_indent_level)
        # we never indent the start
        hash_string = "{\n"
        hash_node.pairs.each do |pair|
          unless pair.left_sibling.nil?
            hash_string << "\n"
          end

          hash_string << child_indent

          if pair.key.str_type?
            hash_string << "'#{pair.key.value}'"
          elsif pair.key.sym_type?
            if pair.hash_rocket?
              hash_string << ":#{pair.key.value}"
            else
              hash_string << pair.key.value.to_s
            end
          else
            hash_string << pair.key.value.to_s
          end

          key_string = pair.delimiter(with_spacing: true)
          hash_string << key_string

          if pair.value.type == :hash
            hash_string << write_hash(pair.value, child_indent_level, child_indent_level + 1)
          else
            hash_string << pair.value.source
          end
          hash_string << ','

          unless pair.right_sibling.nil?
            hash_string << "\n"
          end
        end
        hash_string << "\n#{indent}}"
      end

      def indent_string(indent_level)
        ' ' * (indent_level * 2)
      end
    end
  end
end
