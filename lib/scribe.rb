require_relative './truncate.rb'
require 'pp'

class Scribe
  attr_accessor :data, :data_store

  def initialize
    @data = {}
    if !File.exists?(Dir.pwd + '/.store')
      @data_store = File.open('.store', 'w')
      @data_store.close
    end
  end

  def write(note)
    content = note.content
    if !note_with_content_exists?(content)
      dumped_note = Marshal.dump(note)
      File.write('.store', dumped_note, mode: 'a')
      File.write('.store', "\n", mode: 'a')
    end

    note
  end

  def read(query)
    result = search(query)
    store.close
    puts format(result)
  end

  def count
    count = store.readlines.count
    store.close
    count
  end

  def list
    store.readlines.each do |line|
      puts format(load(line))
    end
  end

  def search query
    notes = read_all
    id_result = notes.find { |n| n.id == query.to_i }
    return id_result if id_result

    exact_content_result = notes.find { |n| n.content == query.to_s }
    return exact_content_result if exact_content_result

    regex_result = notes.find { |n| n.content.match(Regexp.new(query, true)) }
    return regex_result if regex_result

    puts 'Query result not found...'
  end
  
  def read_all
    store.readlines.map { |line| load(line) }
  end

  def store
    File.open('.store', 'r+')
  end

  def load object
    Marshal.load(object)
  end

  def dump object
    Marshal.dump(object)
  end

  def format note
    return "NIL" if !note
    " - #{note.content.truncate(20)}\t\t -|- #{note.id} -|- #{note.parent}"
  end

  def note_with_content_exists? content
    read_all.map(&:content).any? { |c| c == content }
  end
end
