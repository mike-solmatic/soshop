# Demo data for SoShop.
#
#   Admin:    admin@soshop.test  / password123
#   Sellers:  bella@soshop.test  / password123  (approved)
#             urban@soshop.test  / password123  (approved)
#             tote@soshop.test   / password123  (pending approval)
#
# Customers sign in via Facebook Connect (mocked in development without
# FACEBOOK_APP_ID). Seeded customers simulate previous Facebook logins.

require "securerandom"

puts "Seeding SoShop demo data…"

Admin.find_or_create_by!(email: "admin@soshop.test") do |admin|
  admin.name = "Platform Owner"
  admin.password = "password123"
end

# Default administrator
Admin.find_or_create_by!(email: "mgimena11@gmail.com") do |admin|
  admin.name = "Mike Gimena"
  admin.password = "123123"
end

SELLERS = [
  { name: "Isabella Cruz", store_name: "Bella Bags", email: "bella@soshop.test", status: :approved },
  { name: "Marcus Chen", store_name: "Urban Carry", email: "urban@soshop.test", status: :approved },
  { name: "Priya Patel", store_name: "Tote & Co", email: "tote@soshop.test", status: :pending }
].freeze

BAGS = [
  [ "Milano Leather Tote", "Tote", 18900 ],
  [ "Weekender Duffel", "Duffel", 14500 ],
  [ "Metro Crossbody", "Crossbody", 8900 ],
  [ "Voyager Backpack", "Backpack", 12900 ],
  [ "Petite Clutch Noir", "Clutch", 6900 ],
  [ "Harbor Messenger", "Messenger", 11500 ],
  [ "Sierra Canvas Satchel", "Satchel", 9900 ],
  [ "Luna Mini Bag", "Mini bag", 7500 ]
].freeze

FIRST = %w[Sofia Liam Maya Noah Ava Lucas Zoe Ethan Chloe Ryan Nina Omar].freeze
LAST  = %w[Garcia Kim Nakamura Okafor Muller Rossi Silva Novak Haddad Jensen].freeze
CITIES = [
  [ "Austin", "TX", "73301" ], [ "Portland", "OR", "97201" ],
  [ "Chicago", "IL", "60601" ], [ "Denver", "CO", "80201" ],
  [ "Seattle", "WA", "98101" ], [ "Miami", "FL", "33101" ]
].freeze

SELLERS.each_with_index do |attrs, seller_index|
  seller = Seller.find_or_initialize_by(email: attrs[:email])
  seller.assign_attributes(
    name: attrs[:name],
    store_name: attrs[:store_name],
    password: "password123",
    status: attrs[:status],
    approved_at: attrs[:status] == :approved ? 60.days.ago : nil
  )
  seller.save!
  next unless seller.approved?

  ActsAsTenant.with_tenant(seller) do
    products = BAGS.each_with_index.map do |(bag_name, category, price), i|
      next if (i + seller_index).odd? && i > 5
      Product.find_or_create_by!(name: bag_name, seller: seller) do |p|
        p.category = category
        p.price_cents = price + (seller_index * 500)
      end
    end.compact

    next if seller.customers.count >= 6

    8.times do |i|
      customer_name = "#{FIRST[(i * 3 + seller_index * 5) % FIRST.size]} #{LAST[(i * 2 + seller_index * 3) % LAST.size]}"
      uid = (10**14 + SecureRandom.random_number(9 * 10**14)).to_s
      customer = Customer.create!(
        seller: seller,
        provider: "facebook",
        uid: uid,
        name: customer_name,
        email: "#{customer_name.downcase.tr(' ', '.')}@example.com",
        avatar_url: "https://i.pravatar.cc/200?u=#{uid}",
        created_at: rand(1..40).days.ago
      )

      city, state, zip = CITIES[(i + seller_index) % CITIES.size]
      Address.create!(
        seller: seller,
        customer: customer,
        label: "Home",
        recipient: customer_name,
        line1: "#{100 + rand(900)} #{%w[Oak Maple Cedar Pine Elm].sample} St",
        city: city, state: state, postal_code: zip, country: "US",
        phone: "+1 555-01#{format('%02d', rand(100) % 100)}",
        default: true
      )
      if i.even?
        Address.create!(
          seller: seller,
          customer: customer,
          label: "Office",
          recipient: customer_name,
          line1: "#{10 + rand(90)} #{%w[Market Main Union Broadway].sample} Ave, Suite #{rand(100..999)}",
          city: city, state: state, postal_code: zip, country: "US"
        )
      end

      rand(1..4).times do
        placed_at = rand(0..13).days.ago.change(hour: rand(8..21))
        items = products.sample(rand(1..3)).map do |product|
          { product: product, quantity: rand(1..2), unit_price_cents: product.price_cents }
        end
        subtotal = items.sum { |it| it[:quantity] * it[:unit_price_cents] }
        shipping = [ 0, 500, 900 ].sample
        status = placed_at > 3.days.ago ? %i[pending processing].sample : %i[processing shipped delivered delivered].sample

        order = Order.create!(
          seller: seller,
          customer: customer,
          shipping_address: customer.default_address,
          status: status,
          subtotal_cents: subtotal,
          shipping_cents: shipping,
          total_cents: subtotal + shipping,
          placed_at: placed_at,
          created_at: placed_at
        )
        items.each do |it|
          OrderItem.create!(order: order, product: it[:product], product_name: it[:product].name,
                            quantity: it[:quantity], unit_price_cents: it[:unit_price_cents])
        end

        payment_status = order.pending? ? %i[pending succeeded].sample : :succeeded
        Payment.create!(
          seller: seller,
          order: order,
          amount_cents: order.total_cents,
          method: %i[card card wallet bank_transfer cash_on_delivery].sample,
          status: payment_status,
          paid_at: payment_status == :succeeded ? placed_at + rand(1..12).hours : nil,
          created_at: placed_at
        )

        Invoice.create!(
          seller: seller,
          order: order,
          status: payment_status == :succeeded ? :paid : :issued,
          amount_cents: order.total_cents,
          issued_on: placed_at.to_date,
          due_on: placed_at.to_date + 14
        )
      end
    end
  end
end

puts "Done. #{Seller.count} sellers, #{Customer.unscoped.count} customers, " \
     "#{Order.unscoped.count} orders, #{Payment.unscoped.count} payments, #{Invoice.unscoped.count} invoices."
