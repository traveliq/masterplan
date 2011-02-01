module Masterplan
  class Document < Hash

    def initialize(hash = {})
      raise ArgumentError, "Can only work with a Hash, not a #{hash.class.name} !" unless hash.is_a?(Hash)
      hash.each do |k, v|
        self[k] = v
      end
    end

    # Turns a Masterplan::Document into a plain Hash - this removes all special
    # objects like Masterplan::Rule and replaces them with their example values, so
    # the result can be used as documentation.
    def to_hash
      result = {}
      each do |k, v|
        result[k] = self.class.derulerize(v)
      end
      result
    end

    private

    def self.derulerize(object)
      case object
      when Hash
        new(object).to_hash
      when Array
        object.map { |e| derulerize(e) }
      when Masterplan::Rule
        derulerize(object.example_value)
      else
        object
      end
    end
  end
end