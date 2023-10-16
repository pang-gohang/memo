# frozen_string_literal: true

class Memo
  attr_accessor :id, :subject, :content

  def initialize(id, subject, content)
    @id = id
    @subject = subject
    @content = content
  end

  def self.add_new_memo(memos, target_memo)
    target_memo.id = memos.map(&:id).max + 1
    memos << target_memo
  end

  def self.update_memo(memos, target_memo)
    memos.each do |memo|
      memo.subject = target_memo.subject if memo.id == target_memo.id
      memo.content = target_memo.content if memo.id == target_memo.id
    end
  end

  def self.persist_memos(memos)
    save_file = memos.map do |memo|
      {
        'id' => memo.id,
        'subject' => memo.subject,
        'content' => memo.content
      }
    end
    File.open('data/memos.json', 'w') do |output_file|
      output_file.write(JSON.pretty_generate(save_file.map { |data| data.transform_keys(&:to_s) }))
    end
  end

  def self.save_memos(memos, target_memo)
    if target_memo.id.nil?
      add_new_memo(memos, target_memo)
    else
      update_memo(memos, target_memo)
    end
    persist_memos(memos)
  end
end
