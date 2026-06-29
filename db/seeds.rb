# Idempotent demo dataset for the ecommerce analytics project.
#
# Re-running this seed removes only records created by this file, then rebuilds
# the same 24-month dataset with deterministic randomness.

require "bigdecimal"
require "set"

SEED_EMAIL_DOMAIN = "xlsx-ecommerce.local"
SEED_PRODUCT_PREFIX = "[seed] "
PURCHASES_PER_MONTH = 92
MONTH_COUNT = 24

rng = Random.new(20260628)

def money(value)
  BigDecimal(value.to_s).round(2)
end

def weighted_pick(rng, pairs)
  total_weight = pairs.sum { |(_, weight)| weight }
  roll = rng.rand * total_weight

  pairs.each do |value, weight|
    roll -= weight
    return value if roll <= 0
  end

  pairs.last.first
end

ActiveRecord::Base.transaction do
  seeded_users = User.where("email LIKE ?", "seed_user_%@#{SEED_EMAIL_DOMAIN}")
  seeded_products = Product.where("name LIKE ?", "#{SEED_PRODUCT_PREFIX}%")

  seeded_user_ids = seeded_users.pluck(:id)
  seeded_product_ids = seeded_products.pluck(:id)
  seeded_cart_ids = Cart.where(user_id: seeded_user_ids).pluck(:id)
  seeded_purchase_ids = Purchase.where(user_id: seeded_user_ids).pluck(:id)

  CartItem.where(cart_id: seeded_cart_ids).delete_all
  ItemPurchase.where(purchase_id: seeded_purchase_ids).delete_all
  Review.where(user_id: seeded_user_ids).or(Review.where(product_id: seeded_product_ids)).delete_all
  Purchase.where(id: seeded_purchase_ids).delete_all
  Cart.where(id: seeded_cart_ids).delete_all
  Coupon.where("code LIKE ?", "SEED%").delete_all
  seeded_products.delete_all
  seeded_users.delete_all

  states = %w[SP RJ MG PR SC RS BA PE CE GO DF ES]
  cities = {
    "SP" => [ "Sao Paulo", "Campinas", "Santos" ],
    "RJ" => [ "Rio de Janeiro", "Niteroi", "Petropolis" ],
    "MG" => [ "Belo Horizonte", "Uberlandia", "Juiz de Fora" ],
    "PR" => [ "Curitiba", "Londrina", "Maringa" ],
    "SC" => [ "Florianopolis", "Joinville", "Blumenau" ],
    "RS" => [ "Porto Alegre", "Caxias do Sul", "Pelotas" ],
    "BA" => [ "Salvador", "Feira de Santana", "Vitoria da Conquista" ],
    "PE" => [ "Recife", "Olinda", "Caruaru" ],
    "CE" => [ "Fortaleza", "Juazeiro do Norte", "Sobral" ],
    "GO" => [ "Goiania", "Anapolis", "Rio Verde" ],
    "DF" => [ "Brasilia", "Taguatinga", "Ceilandia" ],
    "ES" => [ "Vitoria", "Vila Velha", "Serra" ]
  }

  users = 180.times.map do |index|
    state = states[index % states.length]
    User.create!(
      name: "Seed Cliente #{index + 1}",
      email: "seed_user_#{format('%03d', index + 1)}@#{SEED_EMAIL_DOMAIN}",
      birth_date: Date.new(1980 + (index % 24), 1 + (index % 12), 1 + (index % 27)),
      state: state,
      city: cities.fetch(state)[index % 3]
    )
  end

  product_specs = [
    [ "Camiseta Essencial", "vestuario", 39.90 ],
    [ "Regata Leve", "vestuario", 29.90 ],
    [ "Moletom Basico", "vestuario", 89.90 ],
    [ "Calca Jogger", "vestuario", 79.90 ],
    [ "Meia Algodao", "vestuario", 19.90 ],
    [ "Bone Urban", "vestuario", 34.90 ],
    [ "Caneca Ceramica", "casa", 24.90 ],
    [ "Garrafa Termica", "casa", 59.90 ],
    [ "Organizador Mesa", "casa", 44.90 ],
    [ "Luminaria Led", "casa", 69.90 ],
    [ "Kit Toalhas", "casa", 84.90 ],
    [ "Almofada Decor", "casa", 49.90 ],
    [ "Caderno Pontilhado", "papelaria", 32.90 ],
    [ "Planner Mensal", "papelaria", 42.90 ],
    [ "Caneta Gel Kit", "papelaria", 27.90 ],
    [ "Marcador Texto", "papelaria", 18.90 ],
    [ "Estojo Slim", "papelaria", 36.90 ],
    [ "Bloco Adesivo", "papelaria", 16.90 ],
    [ "Fone Bluetooth", "eletronicos", 99.90 ],
    [ "Cabo Usb C", "eletronicos", 22.90 ],
    [ "Carregador Turbo", "eletronicos", 54.90 ],
    [ "Mouse Sem Fio", "eletronicos", 64.90 ],
    [ "Suporte Notebook", "eletronicos", 74.90 ],
    [ "Power Bank", "eletronicos", 89.90 ],
    [ "Sabonete Artesanal", "beleza", 17.90 ],
    [ "Hidratante Corporal", "beleza", 44.90 ],
    [ "Necessaire", "beleza", 39.90 ],
    [ "Escova Facial", "beleza", 34.90 ],
    [ "Oleo Capilar", "beleza", 49.90 ],
    [ "Kit Skincare", "beleza", 94.90 ],
    [ "Cafe Especial", "alimentos", 38.90 ],
    [ "Granola Premium", "alimentos", 31.90 ],
    [ "Mel Silvestre", "alimentos", 29.90 ],
    [ "Chocolate 70", "alimentos", 21.90 ],
    [ "Castanhas Mix", "alimentos", 46.90 ],
    [ "Cha Sortido", "alimentos", 25.90 ]
  ]

  products = product_specs.map.with_index do |(name, category, price), index|
    Product.create!(
      name: "#{SEED_PRODUCT_PREFIX}#{name}",
      category: category,
      price: money(price),
      cost_price: money(price * (0.43 + (index % 5) * 0.04)),
      stock: 80 + rng.rand(220),
      active: true
    )
  end

  [
    [ "SEED10", :fixed_amount, 10, 1.year.from_now ],
    [ "SEED5OFF", :percentage, 5, 6.months.from_now ],
    [ "SEEDFRETE", :fixed_amount, 8.90, nil ]
  ].each do |code, discount_type, discount_value, expires_at|
    Coupon.create!(
      code: code,
      discount_type: discount_type,
      discount_value: money(discount_value),
      active: true,
      expires_at: expires_at
    )
  end

  start_month = Date.current.beginning_of_month - (MONTH_COUNT - 1).months
  reviewed_pairs = Set.new

  MONTH_COUNT.times do |month_index|
    month = start_month + month_index.months
    days_in_month = Time.days_in_month(month.month, month.year)

    PURCHASES_PER_MONTH.times do |purchase_index|
      user = users.sample(random: rng)
      purchased_at = Time.zone.local(
        month.year,
        month.month,
        1 + rng.rand(days_in_month),
        8 + rng.rand(14),
        rng.rand(60),
        rng.rand(60)
      )

      item_count = weighted_pick(rng, [ [ 1, 58 ], [ 2, 34 ], [ 3, 8 ] ])
      chosen_products = products.sample(item_count, random: rng)

      item_rows = chosen_products.map do |product|
        quantity = product.price <= 30 && rng.rand < 0.18 ? 2 : 1
        unit_price = product.price
        subtotal = money(unit_price * quantity)

        { product: product, quantity: quantity, unit_price: unit_price, subtotal: subtotal }
      end

      subtotal = money(item_rows.sum { |item| item.fetch(:subtotal) })
      shipping_cost = money(weighted_pick(rng, [ [ 0, 45 ], [ 8.90, 35 ], [ 12.90, 20 ] ]))
      discount_amount = if rng.rand < 0.22
        money([ subtotal * 0.08, 12 ].min)
      else
        money(0)
      end
      total_amount = money(subtotal + shipping_cost - discount_amount)

      purchase = Purchase.create!(
        user: user,
        status: weighted_pick(rng, [ [ :paid, 72 ], [ :shipped, 24 ], [ :pending, 4 ] ]),
        payment_method: weighted_pick(rng, [ [ :pix, 42 ], [ :credit_card, 43 ], [ :debit_card, 15 ] ]),
        purchase_date: purchased_at,
        subtotal: subtotal,
        shipping_cost: shipping_cost,
        discount_amount: discount_amount,
        total_amount: total_amount
      )

      item_rows.each do |item|
        ItemPurchase.create!(
          purchase: purchase,
          product: item.fetch(:product),
          quantity: item.fetch(:quantity),
          unit_price: item.fetch(:unit_price),
          subtotal: item.fetch(:subtotal)
        )
      end

      review_key = [ user.id, chosen_products.first.id ]
      next unless purchase_index % 9 == 0 && reviewed_pairs.add?(review_key)

      Review.create!(
        user: user,
        product: chosen_products.first,
        rating: weighted_pick(rng, [ [ 5, 50 ], [ 4, 35 ], [ 3, 12 ], [ 2, 2 ], [ 1, 1 ] ]),
        comment: "Avaliacao gerada para o dataset analitico."
      )
    end
  end

  users.sample(55, random: rng).each do |user|
    cart = Cart.create!(user: user, status: weighted_pick(rng, [ [ :open, 70 ], [ :abandoned, 30 ] ]))
    products.sample(1 + rng.rand(3), random: rng).each do |product|
      quantity = 1 + rng.rand(2)
      CartItem.create!(
        cart: cart,
        product: product,
        quantity: quantity,
        unit_price: product.price,
        subtotal: money(product.price * quantity)
      )
    end
  end
end

puts "Seed complete"
puts "Users: #{User.count}"
puts "Products: #{Product.count}"
puts "Purchases: #{Purchase.count}"
puts "Average ticket: #{(Purchase.sum(:total_amount) / Purchase.count).round(2)}"
