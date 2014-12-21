class CreateExtLinks < ActiveRecord::Migration
  def change
    create_table :ext_links do |t|
      t.string :url
      t.string :ext_site
      t.references :linkable, polymorphic: true

      t.timestamps
    end
    add_index :ext_links, [:linkable_id, :linkable_type]
  end
end
