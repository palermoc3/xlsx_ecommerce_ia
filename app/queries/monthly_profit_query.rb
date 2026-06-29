class MonthlyProfitQuery
  def initialize(period: 1.year.ago..Time.current)
    @period = period
  end

  def call
    ItemPurchase
      .joins(:purchase, :product)
      .merge(Purchase.completed.where(purchase_date: period))
      .group(month_expression)
      .select(
        "#{month_expression} AS month",
        "COUNT(DISTINCT purchases.id) AS purchase_count",
        "SUM(item_purchases.subtotal) AS item_revenue",
        "SUM(products.cost_price * item_purchases.quantity) AS item_cost",
        "SUM(item_purchases.subtotal - (products.cost_price * item_purchases.quantity)) AS gross_profit"
      )
      .order("month ASC")
  end

  private
    attr_reader :period

    def month_expression
      "strftime('%Y-%m', purchases.purchase_date)"
    end
end
