class CreateExtLinks < ActiveRecord::Migration
  def change
    create_table :ext_links do |t|
      t.string :url
      t.string :ext_site
      t.references :linkable, index: true

      t.timestamps
    end
  end
end
