class Note
  attr_reader :content, :parent, :id
  
  def initialize content, parent=nil
    @content = content
    @id = gen_id
    @parent = parent    
  end

  def gen_id
    Time.now.strftime("%Y%m%d%k%M%S%L").to_i.to_s(36).to_i(36)[0..7]
  end
end
