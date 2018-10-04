require 'forwardable'

# Responsible for all string to type coercions.
class ENVied::Coercer
  extend Forwardable
  SUPPORTED_TYPES = [:env, :hash, :array, :time, :date, :symbol, :boolean, :integer, :string, :uri, :float].sort

  UnsupportedCoercion = Class.new(StandardError)

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
    if self.class.built_in_type?(type)
      coercer.public_send("to_#{type.downcase}", string)
    elsif self.class.custom_type?(type)
      custom_types[type].coerce(string)
    else
      raise ArgumentError, "The type `#{type.inspect}` is not supported."
    end
  end

  def self.built_in_type?(type)
    SUPPORTED_TYPES.include?(type)
  end

  def self.custom_type?(type)
    custom_types.key?(type)
  end

  # Custom types container.
  #
  # @example
  #   ENVied::Coercer.custom_types[:json] =
  #     ENVied::Type.new(:json, ->(str) { JSON.parse(str) })
  #
  # @return
  def self.custom_types
    @custom_types ||= {}
  end

  def self.supported_types
    SUPPORTED_TYPES + custom_types.keys
  end

  # Whether or not Coercer can coerce strings to the provided type.
  #
  # @param type [#to_sym] the type (case insensitive)
  #
  # @example
  #   ENVied::Coercer.supported_type?('string')
  #   # => true
  #
  # @return [Boolean] whether type is supported.
  def self.supported_type?(type)
    name = type.to_sym.downcase
    built_in_type?(name) || custom_type?(name)
  end

  def_delegators :'self.class', :supported_type?, :supported_types, :custom_types

  def supported_type?(type)
    self.class.supported_type?(type)
  end

  def supported_types
    self.class.supported_types
  end

  def coercer
    @coercer ||= ENViedString.new
  end

  def coerced?(value)
    !value.kind_of?(String)
  end

  def coercible?(string, type)
    return false unless supported_type?(type)
    coerce(string, type)
    true
  rescue UnsupportedCoercion
    false
  end
end
