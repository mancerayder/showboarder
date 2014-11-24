class AddAttachmentHeaderImageToBoards < ActiveRecord::Migration
  def self.up
    change_table :boards do |t|
      t.attachment :header_image
    end
  end

  def self.down
    remove_attachment :boards, :header_image
  end
end
