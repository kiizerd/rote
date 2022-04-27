require 'securerandom'

class Note
  attr_reader :content, :parent, :id
  
  def initialize content, parent=nil
    @content = content
    @id = gen_id
    @parent = parent    
  end

  def gen_id
    SecureRandom.uuid.split('-').first
  end
end
