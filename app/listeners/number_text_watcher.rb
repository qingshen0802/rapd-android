class NumberTextWatcher

  attr_accessor :target,:action, :edittext, :action, :first, :updated, :origin, :u_value, :o_value

  def initialize(target, edittext, action)
    self.target = target
    self.action = action
    @edittext = edittext
    @first = true
  end

  def afterTextChanged(s)
    last_char = s.toString.split('').last
    @updated = @edittext.getText.length
    @edittext.removeTextChangedListener(self)
    s = s.toString.gsub(/[.]/, "")
    s = s.toString.gsub(/[,]/, ".")
    if @first
      value = s.toString.to_f/100
      @first = false
    elsif @origin <= @updated
      if s.toString.indexOf(".") == s.toString.length - 2
        value = s.toString.to_f/10
      else
        value = s.toString.to_f*10
      end
    elsif @origin > @updated
      value = s.toString.to_f/10
    end
    value = value.round(2)
    if value.to_f == 0
      value = "0.00"
    end
    @origin = @edittext.getText.length
    if last_char == "0" && value.to_f != 0
      value = value.toString.gsub(/[.]/, ',').gsub(/(\d)(?=(\d{3})+\,\b)/,'\1.')
      @edittext.setText("#{value.toString}0")
    else
      value = value.toString.gsub(/[.]/, ',').gsub(/(\d)(?=(\d{3})+\,\b)/,'\1.')
      @edittext.setText(value.toString)
    end
    @edittext.setSelection(@edittext.getText.length)
    @edittext.addTextChangedListener(self)
    if action != nil
      target.send(action)
    end
  end

  def onTextChanged(s, start, before, count)
  end

  def beforeTextChanged(s, start, count, after)

  end
end