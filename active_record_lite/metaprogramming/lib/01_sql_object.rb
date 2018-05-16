require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  attr_reader :table_name
  def self.columns
    # ...
    return @columns.first.map(&:to_sym) if @columns

    array_of_hashes = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    @columns = array_of_hashes
    array_of_hashes.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |name|
      define_method("#{name}") do
        attributes[name]
      end

      define_method("#{name}=") do |val|
        attributes[name] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
    self.table_name = self.name.downcase + 's'
    # ...
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
      self.parse_all(all)
        # ...
  end

  def self.parse_all(results)
    # ...

    results.map {|object| self.new(object)}

  end

  def self.find(id)
    # ...
    object = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
      SQL
    return nil if object.empty?
    self.new(object.first)
  end

  def initialize(params = {})
    params.each do |attr_name, v|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      self.send("#{attr_name}=", v)
    end
    # ...
  end

  def attributes
    # ...
    @attributes || @attributes = {}
  end

  def attribute_values
    # ...
    self.class.columns.map {|col| self.send(col)}
  end

  def insert
    #
    cols = self.class.columns.drop(1).join(', ')
    vals = attribute_values.drop(1)
    question_marks = (["?"] * vals.length).join(", ")

    DBConnection.execute(<<-SQL, vals)
      INSERT INTO
        #{self.class.table_name} (#{cols})
      VALUES
        (#{question_marks})
    SQL
    last_id = DBConnection.last_insert_row_id
    self.id = last_id

  end

  def update
    # ...
    cols = self.class.columns.drop(1).map {|col| "#{col} = ?"}
    vals = attribute_values.drop(1)
    DBConnection.execute(<<-SQL, vals, self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{cols.join(', ')}
    WHERE
      id = ?
    SQL
  end

  def save
    # ...
    if self.id.nil?
      insert
    else
      update
    end
  end
end
