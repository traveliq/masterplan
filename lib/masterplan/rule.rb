module Masterplan
  class Rule

    OPTIONS = ["allow_nil", "compare_each", "included_in", "matches"]

    attr_accessor :options, :example_value

    def initialize(example, options = {})
      options.stringify_keys!
      options['allow_nil'] ||= false
      options['compare_each'] ||= false
      options["included_in"] ||= false
      options["matches"] ||= false
      raise ArgumentError, "options can be #{OPTIONS.join(',')}, not #{options.keys.inspect}" unless options.keys.sort == OPTIONS.sort
      self.example_value = example
      self.options = options
      self.masterplan_compare(example, "initialization of rule")
    end

    def masterplan_compare(value, path)
#      puts "#{path} #{@masterplan_rule_options.inspect}"
#      puts self.inspect
#      puts value.inspect
#      puts @masterplan_rule_options["included_in"].inspect
#      puts !@masterplan_rule_options["included_in"].include?(value) if @masterplan_rule_options["included_in"]
      return true if masterplan_check_allowed_nil!(value, path)
      return true if masterplan_check_included_in!(value, path)
      return true if masterplan_check_matches!(value, path)
      return true if masterplan_check_class_equality!(value, path)
    end

    def self.check_class_equality!(template, value, path)

      value_klass = case value
        when Document
          Hash
        when Rule
          value.example_value.class
        else
          value.class
      end
      template_klass = case template
        when Document
          Hash
        when Rule
          template.example_value.class
        else
          template.class
      end
      if template_klass != value_klass
        raise FailedError, "value at #{path} (#{value_klass}) is not a #{template_klass} !"
      else
        true
      end
    end

    private

    def masterplan_check_class_equality!(value, path)
      self.class.check_class_equality!(self, value, path)
    end

    def masterplan_check_allowed_nil!(value, path)
      if options['allow_nil']
        if value.nil?
          true
        else
          false
        end
      else
        false
      end
    end

    def masterplan_check_included_in!(value, path)
      if options["included_in"]
        unless options["included_in"].include?(value)
          raise Masterplan::FailedError, "value at #{path} #{value.inspect} (#{value.class}) is not one of #{options["included_in"].inspect} !"
        else
          true
        end
      else
        false
      end
    end

    def masterplan_check_matches!(value, path)
      if options["matches"]
        if value !~ options["matches"]
          raise Masterplan::FailedError, "value at #{path} #{value.inspect} (#{value.class}) does not match #{options["matches"].inspect} !"
        else
          true
        end
      else
        false
      end
    end
  end
end
