class CreateExtLinks < ActiveRecord::Migration
  def change
    create_table :ext_links do |t|
      t.string :url
      t.references :linkable, index: true

      t.timestamps
    end
  end
end
