require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
			:class_name => "#{name.camelcase}",
			:primary_key => :id,
    	:foreign_key => "#{name}_id".to_sym
    }
		
		defaults.keys.each do |key|
			self.send("#{key}=", options[key] || defaults[key])
		end		
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
			:class_name => "#{name.singularize.camelcase}",
			:primary_key => :id,
    	:foreign_key => "#{self_class_name.underscore}_id".to_sym
    }
		
		defaults.keys.each do |key|
			self.send("#{key}=", options[key] || defaults[key])
		end		
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
		options = 
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
