require 'optparse'
require 'pp'

class Parser
  Version = '0.1'

  class RoteOptions
    attr_reader :options

    def initialize
      @options = {}
    end

    def define_options(parser)
      parser.banner = 'Usage: rote [options]'
      parser.separator ''
      parser.separator 'Specific options:'

      # Additional options
      create_note_option(parser)
      list_notes_option(parser)
      read_note_option(parser)
      search_notes_option(parser)

      parser.separator 'Common options:'
      parser.on_tail('-h', '--help', "Show this message") do
        puts parser
        exit
      end

      parser.on_tail('-v', '--version', 'Show version') do
        puts Version
        exit
      end
    end

    def create_note_option parser
      parser.on('-n', '--new CONTENT', 'Create new note') do |content|
        @options[:action] = :new
        @options[:content] = content
      end

      parser.on('-p', '--parent PARENT', 'Sets new note as subnote of PARENT') do |parent|
        raise 'CantSetParentOfNil' if @options[:action] != :new

        @options[:parent] = parent
      end
    end

    def list_notes_option parser
      parser.on('-l', '--list', 'Lists top level notes') do
        @options[:action] = :list
      end
    end

    def read_note_option parser
      parser.on('-r', '--read QUERY', 'Reads first note matching QUERY') do |query|
        @options[:action] = :read
        @options[:query] = query
      end
    end

    def search_notes_option parser
      parser.on('-s', '--search QUERY', 'Reads all notes matching QUERY') do |query|
        @options[:action] = :search
        @options[:query] = query
      end
    end
  end

  def parse(args)
    # The options specified on the command line
    # will be collection in *options*
  
    @options = RoteOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    end

    @options.options
  end

  attr_reader :parser, :options
end # class Parser
