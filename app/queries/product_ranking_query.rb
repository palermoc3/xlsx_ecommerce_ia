class ProductRankingQuery
  def initialize(period: 1.year.ago..Time.current, limit: 10)
    @period = period
    @limit = limit
  end

  def call
    ItemPurchase
      .joins(:product, :purchase)
      .merge(Purchase.completed.where(purchase_date: period))
      .group("products.id", "products.name", "products.category")
      .select(
        "products.id AS product_id",
        "products.name AS product_name",
        "products.category AS category",
        "SUM(item_purchases.quantity) AS quantity_sold",
        "SUM(item_purchases.subtotal) AS revenue"
      )
      .order(Arel.sql("revenue DESC, quantity_sold DESC, product_name ASC"))
      .limit(limit)
  end

  private
    attr_reader :period, :limit
end
