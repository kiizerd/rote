#!/usr/bin/env ruby

require 'pry'

require_relative '../lib/parser.rb'
require_relative '../lib/scribe.rb'
require_relative '../lib/note.rb'
require_relative '../lib/factory.rb'

class Interface
  attr_reader :scribe

  def initialize
    @parser = Parser.new
    @scribe = Scribe.new
  end

  def entry args
    data = @parser.parse(args)
    return if !data[:action]

    case data[:action]
    when :new
      note = Factory.build(data)
      @scribe.write(note)
    when :list
      @scribe.list
    else
      puts 'Interface::UnknownAction'
    end
  end
end

interface = Interface.new
interface.entry(ARGV)

# binding.pry
