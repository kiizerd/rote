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
    when :new then @scribe.write(Factory.build(data))
    when :list then @scribe.list
    when :read then @scribe.read(data[:query])
    when :search then @scribe.read(data[:query], false)
    when :delete then @scribe.delete(data[:id])
    else
      puts 'Interface::UnknownAction'
    end
  end
end

interface = Interface.new
interface.entry(ARGV)

# binding.pry
