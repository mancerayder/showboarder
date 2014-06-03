class Transaction < ActiveRecord::Base

  # has_paper_trail

  belongs_to :actioner, polymorphic: true
  belongs_to :actionee, polymorphic: true

  def self.create_for_cart(options={})
    transaction = new do |t|
      t.product_id = options[:product].idf
      t.email = options[:email]
      t.stripe_token = options[:stripe_token]
      t.opt_in = options[:opt_in]
      t.affiliate_id = options[:affiliate].try(:id)

      if options[:coupon_id]
        t.coupon = Coupon.find(options[:coupon_id])
        t.amount = options[:product].price * (1 - t.coupon.percent_off / 100.0)
      else
        t.amount = options[:product].price
      end
    end
    transaction
  end  
end


  # def self.sale(actioner, )

  # end

  #     create_table :transactions do |t|
  #     t.references :actioner, polymorphic: true
  #     t.references :actionee, polymorphic: true
  #     t.string :state_before
  #     t.string :state_after      
  #     t.string :error
  #     t.string :stripe_id
  #     t.string :stripe_token
  #     t.text :error
  #     t.integer :amount
  #     t.integer :fee_amount
  #     t.integer :coupon_id
  #     t.integer :affiliate_id
  #     t.text :customer_address