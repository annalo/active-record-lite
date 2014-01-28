require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
		results.map { |result| self.new(result) }
  end
end

class SQLObject < MassObject
  # sets the table_name
  def self.table_name=(table_name)
		@table_name = table_name
  end

  # gets the table_name
  def self.table_name
		@table_name || self.name.underscore.pluralize
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
  def self.all
		results = DBConnection.execute(<<-SQL)
			SELECT *
			FROM #{self.table_name}
		SQL
				
		self.parse_all(results)
  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
		results = DBConnection.execute(<<-SQL, id)
			SELECT *
			FROM #{self.table_name}
			WHERE #{self.table_name}.id = ?
		SQL
	
		self.parse_all(results).first
  end

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection
  def insert
		attr_names = self.class.attributes.join(", ")
		question_marks = (['?'] * self.class.attributes.count).join(", ")
		
		DBConnection.execute(<<-SQL, *attribute_values)
			INSERT INTO #{self.class.table_name} (#{attr_names})
			VALUES (#{question_marks})
		SQL
		
		self.id = DBConnection.last_insert_row_id
  end

  # call either create or update depending if id is nil.
  def save
		self.id.nil? ? self.insert : self.update
  end

  # executes query that updates the row in the db corresponding to this instance
  # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
  def update
    set_line = self.class.attributes.map { |attr| "#{attr} = ?" }.join(", ")
		
		DBConnection.execute(<<-SQL, *attribute_values, id)
			UPDATE #{self.class.table_name}
			SET #{set_line}
			WHERE #{self.class.table_name}.id = ?
		SQL
  end

  # helper method to return values of the attributes.
  def attribute_values
		self.class.attributes.map { |attr| self.send(attr) }
  end
end