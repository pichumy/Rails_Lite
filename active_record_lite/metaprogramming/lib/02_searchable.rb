require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    keys = params.keys.map {|col| "#{col} = ?"}
    vals = params.values
    object = DBConnection.execute(<<-SQL, vals)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{keys.join(' AND ')}
    SQL
    # ...
    return [] if object.empty?
    object.map {|object| self.new(object) }
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
