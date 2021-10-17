require 'rspec'
require 'parser/ruby24'
require 'rubocop-ast'

describe 'utils_spec' do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  def create_parser
    builder = RuboCop::AST::Builder.new
    Parser::Ruby24.new builder
  end

  def create_buffer(name, source)
    Parser::Source::Buffer.new(name, **{ source: source })
  end

  describe '.combine_hashes(first_node, second_node, tree_rewriter)' do
    context 'first_node is not a hash' do
      it 'returns nil' do
        parser = create_parser

        first_node = parser.parse(create_buffer('first_node', 'x = 1'))

        parser.reset

        second_node = parser.parse(create_buffer('second_node', '{"x" => 1}'))

        return_val = WorkatoConnectorBuilder::Utils.combine(first_node, second_node, nil)
        expect(return_val).to be_nil
      end
    end

    context 'second_node is not a hash' do
      it 'returns nil' do
        parser = create_parser

        first_node = parser.parse(create_buffer('second_node', '{"x" => 1}'))

        parser.reset

        second_node = parser.parse(create_buffer('first_node', 'x = 1'))

        return_val = WorkatoConnectorBuilder::Utils.combine(first_node, second_node, nil)
        expect(return_val).to be_nil
      end
    end

    context 'gets_duplicate_keys' do
      it 'returns nil' do
        parser = create_parser

        first_node = parser.parse(create_buffer('second_node', '{"x" => 1}'))

        parser.reset

        second_node = parser.parse(create_buffer('first_node', 'x = 1'))

        return_val = WorkatoConnectorBuilder::Utils.combine(first_node, second_node, nil)
        expect(return_val).to be_nil
      end
    end
  end
end