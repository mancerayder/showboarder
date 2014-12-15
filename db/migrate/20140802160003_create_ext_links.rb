class CreateExtLinks < ActiveRecord::Migration
  def change
    create_table :ext_links do |t|
      t.string :url
      t.string :ext_site
      t.references :linkable, polymorphic: true

      t.timestamps
    end
  end
end
