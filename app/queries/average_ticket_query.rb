class AverageTicketQuery
  MONTH_EXPRESSION = "strftime('%Y-%m', purchases.purchase_date)".freeze

  def initialize(period: 1.year.ago..Time.current)
    @period = period
  end

  def call
    Purchase.completed
      .where(purchase_date: period)
      .group(Arel.sql(MONTH_EXPRESSION))
      .select(
        Arel.sql("#{MONTH_EXPRESSION} AS month"),
        Arel.sql("COUNT(*) AS purchase_count"),
        Arel.sql("SUM(total_amount) AS revenue"),
        Arel.sql("ROUND(SUM(total_amount) / COUNT(*), 2) AS avg_ticket")
      )
      .order("month ASC")
  end

  private
    attr_reader :period
end
