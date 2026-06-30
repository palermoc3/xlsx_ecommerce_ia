class MonthlyProfitQuery
  MONTH_EXPRESSION = "strftime('%Y-%m', purchases.purchase_date)".freeze

  def initialize(period: 1.year.ago..Time.current)
    @period = period
  end

  def call
    ItemPurchase
      .joins(:purchase, :product)
      .merge(Purchase.completed.where(purchase_date: period))
      .group(Arel.sql(MONTH_EXPRESSION))
      .select(
        Arel.sql("#{MONTH_EXPRESSION} AS month"),
        Arel.sql("COUNT(DISTINCT purchases.id) AS purchase_count"),
        Arel.sql("SUM(item_purchases.subtotal) AS item_revenue"),
        Arel.sql("SUM(products.cost_price * item_purchases.quantity) AS item_cost"),
        Arel.sql("SUM(item_purchases.subtotal - (products.cost_price * item_purchases.quantity)) AS gross_profit")
      )
      .order("month ASC")
  end

  private
    attr_reader :period
end
