class AverageTicketQuery
  def initialize(period: 1.year.ago..Time.current)
    @period = period
  end

  def call
    Purchase.completed
      .where(purchase_date: period)
      .group(month_expression)
      .select(
        "#{month_expression} AS month",
        "COUNT(*) AS purchase_count",
        "SUM(total_amount) AS revenue",
        "ROUND(SUM(total_amount) / COUNT(*), 2) AS avg_ticket"
      )
      .order("month ASC")
  end

  private
    attr_reader :period

    def month_expression
      "strftime('%Y-%m', purchases.purchase_date)"
    end
end
