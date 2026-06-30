class AddUniqueIndexToReviewsUserProduct < ActiveRecord::Migration[8.1]
  def up
    deduplicate_reviews
    add_index :reviews, [ :user_id, :product_id ], unique: true
  end

  def down
    remove_index :reviews, [ :user_id, :product_id ]
  end

  private
    def deduplicate_reviews
      duplicates = select_all(<<~SQL.squish)
        SELECT user_id, product_id, MIN(id) AS keep_id
        FROM reviews
        GROUP BY user_id, product_id
        HAVING COUNT(*) > 1
      SQL

      duplicates.each do |row|
        execute <<~SQL.squish
          DELETE FROM reviews
          WHERE user_id = #{connection.quote(row.fetch("user_id"))}
            AND product_id = #{connection.quote(row.fetch("product_id"))}
            AND id <> #{connection.quote(row.fetch("keep_id"))}
        SQL
      end
    end
end
