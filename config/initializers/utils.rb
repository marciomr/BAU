class String
  def singular
    self[0...-1]
  end
end

class Fixnum
  def to_roman
    return "" if self == 0
    return "I"*self if self < 4
    return "IV" if self == 4 
    return "V" + (self - 5).to_roman if self < 9
    return "IX" if self == 9
    return "X"*(self/10) + (self%10).to_roman if self < 40
    return "XL" + (self - 40).to_roman if self < 50
    return "L" + (self - 50).to_roman if self < 90
  end
end
