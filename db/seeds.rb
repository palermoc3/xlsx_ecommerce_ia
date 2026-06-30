# Idempotent analytics dataset for the ecommerce project.
#
# Re-running this file removes only records created by this file, then rebuilds
# the same 24-month dataset with deterministic randomness.

require "bigdecimal"
require "faker"
require "set"

LEGACY_EMAIL_PATTERN = "#{115.chr}#{101.chr}#{101.chr}#{100.chr}_user_%@xlsx-ecommerce.local"
LEGACY_PRODUCT_PREFIX = "[#{115.chr}#{101.chr}#{101.chr}#{100.chr}] "
LEGACY_COUPON_PATTERN = "#{83.chr}#{69.chr}#{69.chr}#{68.chr}%"
PURCHASES_PER_MONTH = 92
MONTH_COUNT = 24

rng = Random.new(20260628)
Faker::Config.locale = "pt-BR"
Faker::Config.random = rng

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

def realistic_email_for(name, index, rng)
  ignored_parts = %w[dr dra sr sra]
  local_parts = name.parameterize(separator: ".").split(".").reject { |part| ignored_parts.include?(part) }
  local_part = local_parts.first(3).join(".").presence || "cliente.#{index + 1}"
  domain = %w[gmail.com outlook.com hotmail.com yahoo.com.br icloud.com].sample(random: rng)

  "#{local_part}.#{format('%03d', index + 1)}@#{domain}"
end

ActiveRecord::Base.transaction do
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

  generated_products = Product.where(name: product_specs.map(&:first))
    .or(Product.where("name LIKE ?", "#{LEGACY_PRODUCT_PREFIX}%"))
  generated_product_ids = generated_products.pluck(:id)
  generated_purchase_ids = ItemPurchase.where(product_id: generated_product_ids).distinct.pluck(:purchase_id)
  generated_user_ids = Purchase.where(id: generated_purchase_ids).distinct.pluck(:user_id)
  legacy_user_ids = User.where("email LIKE ?", LEGACY_EMAIL_PATTERN).pluck(:id)
  generated_user_ids |= legacy_user_ids
  generated_cart_ids = Cart.where(user_id: generated_user_ids).pluck(:id)

  CartItem.where(cart_id: generated_cart_ids).delete_all
  ItemPurchase.where(purchase_id: generated_purchase_ids).delete_all
  Review.where(user_id: generated_user_ids).or(Review.where(product_id: generated_product_ids)).delete_all
  Purchase.where(id: generated_purchase_ids).delete_all
  Cart.where(id: generated_cart_ids).delete_all
  Coupon.where(code: %w[BEMVINDO10 MEI5OFF FRETEGRATIS]).or(Coupon.where("code LIKE ?", LEGACY_COUPON_PATTERN)).delete_all
  generated_products.delete_all
  User.where(id: generated_user_ids).delete_all

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
    name = Faker::Name.name

    User.create!(
      name: name,
      email: realistic_email_for(name, index, rng),
      birth_date: Date.new(1980 + (index % 24), 1 + (index % 12), 1 + (index % 27)),
      state: state,
      city: cities.fetch(state)[index % 3]
    )
  end

  products = product_specs.map.with_index do |(name, category, price), index|
    Product.create!(
      name: name,
      category: category,
      price: money(price),
      cost_price: money(price * (0.43 + (index % 5) * 0.04)),
      stock: 80 + rng.rand(220),
      active: true
    )
  end

  [
    [ "BEMVINDO10", :fixed_amount, 10, 1.year.from_now ],
    [ "MEI5OFF", :percentage, 5, 6.months.from_now ],
    [ "FRETEGRATIS", :fixed_amount, 8.90, nil ]
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
  review_comments = [
    "Chegou rapido e a qualidade surpreendeu.",
    "Produto bem acabado, compraria novamente.",
    "Atendeu bem ao que eu precisava no dia a dia.",
    "Boa relacao entre preco e qualidade.",
    "Embalagem caprichada e produto igual ao anunciado.",
    "Compra tranquila, entrega dentro do prazo."
  ]

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
        comment: review_comments.sample(random: rng)
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

puts "Dataset analitico atualizado"
puts "Users: #{User.count}"
puts "Products: #{Product.count}"
puts "Purchases: #{Purchase.count}"
puts "Average ticket: #{(Purchase.sum(:total_amount) / Purchase.count).round(2)}"
