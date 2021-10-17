require 'thor'
require_relative './build_command'

module WorkatoConnectorBuilder
  module CLI
    class CLI < Thor
      package_name "WorkatoConnectorBuilder"
      map "-L" => :list


      desc 'build <source_dir> <output_file>', ''
      method_option :ignored_file, type: :string, repeatable: true
      method_option :ignored_dir, type: :string, repeatable: true
      method_option :help, type: :boolean, aliases: ['-h']
      def build(path = nil, output_file = nil)
        if options[:help]
          help('build')
          return 0
        end

        say "Beginning build of source files from #{path}, output file #{output_file}"
        ignored_files = options[:ignored_file] || []
        ignored_dirs = options[:ignored_dir] || []
        BuildCommand.new(
          @shell,
          path,
          output_file,
          ignored_files,
          ignored_dirs
        ).exec
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end
