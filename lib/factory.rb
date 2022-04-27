require_relative './note.rb'

class Factory
  # Note = Struct.new(:content, :id)
  # heirarchy
  # - Parent                { id: id, parent: nil }
  # - - FirstChild          { id: id, parent: ParentId }
  # - - - FirstGrandChild   { id: id, parent: FirstChildId }
  # - - - SecondGrandChild
  # - - SecondChild
  # - - - ThirdGrandChild { id: id, parent: SecondChildId }

  def self.build(data)
    action = data[:action]
    case action
    when :new  then new_note(data)
    when :edit then edit_note(data)
    else
      raise 'Factory::UnknownAction'
    end
  end

  def self.new_note(data)
    content = data[:content]
    parent = data[:parent]
    note = Note.new(content, parent)
  end

  def self.edit_note(data)
    
  end
end
