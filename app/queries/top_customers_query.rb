class TopCustomersQuery
  def initialize(period: 1.year.ago..Time.current, limit: 10)
    @period = period
    @limit = limit
  end

  def call
    User
      .joins(:purchases)
      .merge(Purchase.completed.where(purchase_date: period))
      .group("users.id", "users.name", "users.email", "users.state")
      .select(
        "users.id AS user_id",
        "users.name AS customer_name",
        "users.email AS email",
        "users.state AS state",
        "COUNT(purchases.id) AS purchase_count",
        "SUM(purchases.total_amount) AS revenue"
      )
      .order(Arel.sql("revenue DESC, purchase_count DESC, customer_name ASC"))
      .limit(limit)
  end

  private
    attr_reader :period, :limit
end
