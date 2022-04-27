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

  def read(query, single=true)
    result = nil

    if single
      result = find(query)
      puts format(result)
    else
      result = find_all(query)
      result.each do |note|
        puts format(note)
      end
    end

    store.close
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

  def find query
    notes = read_all
    id_result = find_by_id(query)
    return id_result if id_result

    exact_content_result = find_by_exact_content(query)
    return exact_content_result if exact_content_result

    regex_result = find_by_match_regex(query.to_s)
    return regex_result if regex_result
  end

  def find_by_id query_id
    read_all.find { |n| n.id == query_id.to_i } rescue nil
  end

  def find_by_exact_content query_content
    read_all.find { |n| n.content == query.to_s } rescue nil
  end

  def find_by_match_regex query_string
    read_all.find { |n| n.content.match(Regexp.new(query_string)) }
  end

  def find_all query
    notes = read_all
    refined_query = refine_query(query)
    if refined_query.is_a?(Range)
      puts 'query range of ids'
      refined_query.map { |i| find_by_id(i) }.compact
    elsif refined_query.is_a?(String)
      puts 'query matching content'
      puts query
      read_all.select { |n| n.content.match(Regexp.new(query, true)) }
    else
      puts refined_query.class, :wtf
    end
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

  def refine_query query
    result = Range.new(*query.split('..').map(&:to_i)) rescue query
    result
  end

  def note_with_content_exists? content
    read_all.map(&:content).any? { |c| c == content }
  end
end
