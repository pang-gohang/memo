# frozen_string_literal: true

class Memo
  attr_accessor :id, :subject, :content

  def initialize(id, subject, content)
    @id = id
    @subject = subject
    @content = content
  end
end
