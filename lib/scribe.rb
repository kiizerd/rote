require_relative './truncate.rb'
require 'tty-table'
require 'tempfile'
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
    table = new_table

    if single
      result = find(query)
      table << note_to_table_row(result)
    else
      result = find_all(query)
      result.each do |note|
        table << note_to_table_row(note)
      end
    end

    store.close
    puts table.render(:ascii, alignment: [:center])
  end
  
  # TODO: break down method, add confirmation before delete
  def delete(note_index)
    windows_like = RUBY_PLATFORM =~ /mswin|mingw|windows/
    filename = '.store'
    tempdir = File.dirname(filename)
    tempprefix = File.basename(filename)
    tempfile = 
    begin
      Tempfile.new(tempprefix, tempdir)
    rescue
      Tempfile.new(tempprefix)
    end
    File.open(filename).each do |line|
      if index(load(line)) != note_index.to_i
        tempfile.puts line 
      end
    end
    tempfile.fdatasync unless windows_like
    tempfile.close
    unless windows_like
      stat = File.stat(filename)
      FileUtils.chown stat.uid, stat.gid, tempfile.path
      FileUtils.chmod stat.mode, tempfile.path
    else
      # FIXME: apply perms on windows
    end
    FileUtils.mv tempfile.path, filename
  end

  def count
    count = store.readlines.count
    store.close
    count
  end

  def list
    table = new_table
    store.readlines.each do |line|
      note = load(line)
      table << note_to_table_row(note)
    end
    puts table.render(:ascii, alignment: [:center])
  end

  def find(query)
    notes = read_all
    index_result = find_by_index(query)
    return index_result if index_result
    id_result = find_by_id(query)
    return id_result if id_result

    exact_content_result = find_by_exact_content(query)
    return exact_content_result if exact_content_result

    regex_result = find_by_match_regex(query.to_s)
    return regex_result if regex_result
  end

  def find_by_index query_index
    read_all.find { |n| index(n) == query_index.to_i }
  end

  def find_by_id(query_id)
    read_all.find { |n| n.id == query_id.to_i } rescue nil
  end

  def find_by_exact_content(query_content)
    read_all.find { |n| n.content == query.to_s } rescue nil
  end

  def find_by_match_regex(query_string)
    read_all.find { |n| n.content.match(Regexp.new(query_string)) }
  end

  def find_all(query)
    notes = read_all
    refined_query = refine_query(query)
    if refined_query.is_a?(Range)
      puts 'query range of indices'
      refined_query.map { |i| find_by_index(i) }.compact
    elsif refined_query.is_a?(String)
      content_result = read_all.select { |n| n.content.match(Regexp.new(query, true)) }
      return content_result if content_result.size > 0
      id_result = read_all.select { |n| n.id.match(Regexp.new(query, true)) }
    else
      puts refined_query.class, :wtf
    end
  end
  
  def read_all
    store.readlines.map { |line| load(line) }
  end

  def index note
    read_all.index { |n| n.id == note.id }
  end

  def store
    File.open('.store', 'r+')
  end

  def load(object)
    Marshal.load(object) rescue ''
  end

  def dump(object)
    Marshal.dump(object)
  end

  def format(note)
    return "NIL" if !note
    " - #{note.content.truncate(20)} -|- [#{index(note)}] -|- #{note.id} -|- #{note.parent}"
  end

  def refine_query(query)
    result = Range.new(*query.split('..').map(&:to_i)) rescue query
    result
  end

  def new_table
    TTY::Table.new(header: ["Note", " Index ", " ID "])
  end

  def note_to_table_row note
    [
      { value: note.content.truncate(26), alignment: :left },
      { value: "[#{index(note)}]", alignment: :center },
      { value: note.id, alignment: :center }
    ]
  end

  def note_with_content_exists?(content)
    read_all.map(&:content).any? { |c| c == content }
  end
end
