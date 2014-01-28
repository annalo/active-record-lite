require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
	# takes a list of attributes.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*new_attributes)
		new_attributes.each { |attribute| self.attributes << attribute.to_sym }
  end

  # returns list of attributes that have been whitelisted.
  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    end

    @attributes ||= [] 
	end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})
		params.each do |attr_name, value|
			# make sure to convert keys to symbols
			attr_name = attr_name.to_sym
			if self.class.attributes.include?(attr_name)
			  self.send("#{attr_name}=", value)
			else
			  raise "mass assignment to unregistered attribute '#{attr_name}'"
			end
		end
  end
end