class String
  def truncate length=26, ellipse=true
    if ellipse
      if self.size > length
        "#{chars[0 ..length-4].join}..."
      else
        return self
      end
    else
      chars[0 ..length-1].join
    end
  end
end