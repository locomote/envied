require 'coercible'

# Responsible for all string to type coercions.
class ENVied::Coercer
  extend Forwardable

  SUPPORTED_TYPES = %i(hash array time date symbol boolean integer string uri float).freeze

  class << self
    def base_type?(type)
      name = type.to_sym.downcase
      supported_types.include?(name)
    end

    def supported_types
      SUPPORTED_TYPES
    end
  end

  def_delegators :'self.class', :base_type?

  # Whether or not Coercer can coerce strings to the provided type.
  #
  # @param type [#to_sym] the type (case insensitive)
  #
  # @example
  #   ENVied::Coercer.new.supported_type?('string')
  #   # => true
  #
  # @return [Hash] of type names and their definitions.
  def supported_type?(type)
    base_type?(type) || custom_type?(type)
  end

  # Whether or not Coercer has the provided type as a custom one.
  #
  # Custom data type can be registered using Configuration#type method.
  #
  # @param type [#to_sym] the type (case insensitive)
  #
  # @example
  #   ENVied::Coercer.new.custom_type?('string')
  #   # => false
  #
  # @return [Hash] of type names and their definitions.
  def custom_type?(type)
    name = type.to_sym.downcase
    custom_types.include?(name)
  end

  # List of custom types.
  def custom_types
    @custom_types ||= []
  end

  def supported_types
    self.class.supported_types + custom_types
  end

  # Coerce strings to specific type.
  #
  # @param string [String] the string to be coerced
  # @param type [#to_sym] the type to coerce to
  #
  # @example
  #   ENVied::Coercer.new.coerce('1', :Integer)
  #   # => 1
  #
  # @return [type] the coerced string.
  def coerce(string, type)
    method = coerce_method_for(type)
    raise ArgumentError, "#{type.inspect} is not supported type" unless method
    method.call(string)
  end

  def coerce_method_for(type)
    method_name = "to_#{type.downcase}"
    if base_type?(type)
      coercer.method(method_name)
    elsif custom_type?(type)
      method(method_name)
    end
  end

  def coercer
    @coercer ||= Coercible::Coercer.new[ENViedString]
  end

  def coerced?(value)
    !value.kind_of?(String)
  end

  def coercible?(string, type)
    return false unless supported_type?(type)
    coerce(string, type)
    true
  rescue Coercible::UnsupportedCoercion
    false
  end
end
