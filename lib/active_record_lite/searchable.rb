require_relative './db_connection'

module Searchable
  # takes a hash like { :attr_name => :search_val1, :attr_name2 => :search_val2 }
  # map the keys of params to an array of  "#{key} = ?" to go in WHERE clause.
  # Hash#values will be helpful here.
  # returns an array of objects
  def where(params)
    where_str = params.keys.map do |column_name|
      "(#{column_name} = ?)"
    end.join(" AND ")
    
    parse_all(DBConnection.execute(<<-SQL, *params.values))
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_str}
    SQL
  end
end