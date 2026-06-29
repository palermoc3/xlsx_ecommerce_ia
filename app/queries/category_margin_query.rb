class CategoryMarginQuery
  def initialize(period: 1.year.ago..Time.current)
    @period = period
  end

  def call
    ItemPurchase
      .joins(:product, :purchase)
      .merge(Purchase.completed.where(purchase_date: period))
      .group("products.category")
      .select(
        "products.category AS category",
        "SUM(item_purchases.subtotal) AS revenue",
        "SUM(products.cost_price * item_purchases.quantity) AS cost",
        "SUM(item_purchases.subtotal - (products.cost_price * item_purchases.quantity)) AS gross_margin",
        "ROUND((SUM(item_purchases.subtotal - (products.cost_price * item_purchases.quantity)) * 100.0) / SUM(item_purchases.subtotal), 2) AS margin_percent"
      )
      .order(Arel.sql("gross_margin DESC, category ASC"))
  end

  private
    attr_reader :period
end
