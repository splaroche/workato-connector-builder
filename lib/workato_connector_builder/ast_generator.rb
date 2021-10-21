module WorkatoConnectorBuilder
  class ASTGenerator
    attr_reader :search_path

    def initialize(search_path, parser, ignored_paths = [], ignored_files = [])
      @parser = parser
      @search_path = search_path
      @ignored_paths = ignored_paths
      @ignored_files = ignored_files
    end

    def get_asts
      walk(search_path)
    end

    def get_ignored_paths
      @ignored_paths.clone
    end

    def get_ignored_files
      @ignored_files.clone
    end

    private

    attr_writer :search_path

    def walk(start)
      absolute_start = File.expand_path(start)
      asts = []
      ignored_paths = @ignored_paths
      ignored_files = @ignored_files
      Dir.foreach(absolute_start) do |f|
        if ignored_paths.include?(f) || ignored_files.include?(f)
          next
        end

        path = File.join(start, f)
        absolute_path = File.join(absolute_start, f)
        # ignore everything starts with . (dir references, hidden dirs/files)
        if f.start_with?('.')
          next
        elsif File.directory?(absolute_path)
          asts.concat self.walk(path)
        elsif f.end_with?('.rb') and !f.start_with?('.')
          ps = RuboCop::AST::ProcessedSource.from_file(path, 2.4)
          comments = ps.ast_with_comments
          nodes = ps.ast

          asts << { ast: nodes, comments: comments, path: path }
        end
      end

      asts
    end
  end
end
