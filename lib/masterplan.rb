require 'active_support'
require 'active_support/version'
if ActiveSupport::VERSION::STRING >= "3.0.0"
  require 'active_support/core_ext'
end
if RUBY_VERSION > '1.9'
  gem 'test-unit'
end
require 'test/unit/assertions'
require 'masterplan'
require 'masterplan/rule'
require 'masterplan/document'
require 'masterplan/define_rules'
require 'unit_test_extensions'
module Masterplan

  class FailedError < Test::Unit::AssertionFailedError
    attr_accessor :printed
  end

  class << self

    def compare(options = {:scheme => {}, :to => {}})
      scheme = options[:scheme]
      testee = options[:to]
      raise ArgumentError, ":to needs to be a hash !" unless testee.is_a?(Hash)
      raise ArgumentError, ":scheme needs to be a Masterplan::Document !" unless scheme.is_a?(Document)
      compare_hash(scheme, testee)
      true
    end

    private

    def compare_value(template, value, path)
      if template.is_a?(Rule)
        template.masterplan_compare(value, path)
      else
        Rule.check_class_equality!(template, value, path)
      end
    end

    def compare_hash(template, testee, trail = ["root"])
      template.stringify_keys!
      testee.stringify_keys!
      raise FailedError, "keys don't match in #{format_path(trail)}:\nexpected:\t#{template.keys.sort.join(',')}\nreceived:\t#{testee.keys.sort.join(',')}" if template.keys.sort != testee.keys.sort
      template.each do |t_key, t_value|
        current_path = trail + [t_key]
        value = testee[t_key]
        compare_value(t_value, value, format_path(current_path))
        if value && t_value.is_a?(Array)
          # all array elements need to be of the same type as the first value in the template
          elements_template = t_value.first
          value.each_with_index do |elements_value, index|
            array_path = current_path + [index]
            compare_value(elements_template, elements_value, format_path(array_path))
            if elements_value.is_a?(Hash)
              compare_hash(elements_template, elements_value, array_path)
            end
          end
        end
        if value.is_a?(Array) && t_value.is_a?(Rule) && t_value.options['compare_each']
          value.each_with_index do |elements_value, index| 
            elements_template = t_value.example_value[index]
            array_path = current_path + [index]
            compare_value(elements_template, elements_value, format_path(array_path))
            if elements_value.is_a?(Hash)
              compare_hash(elements_template, elements_value, array_path)
            end
          end
        end
        if value.is_a?(Hash)
          if t_value.is_a?(Masterplan::Rule)
            compare_value(t_value, value, current_path)
            compare_hash(t_value.example_value, value, current_path)
          else
            compare_hash(t_value, value, current_path)
          end
        end
      end

    rescue Masterplan::FailedError => e
      raise e if e.printed

      error = Masterplan::FailedError.new
      error.printed = true

      expected = PP.pp(template, '')
      outcome = PP.pp(testee, '')

      raise error, "#{e.message}\n\nExpected:\n#{expected}\n\nbut was:\n#{outcome}", caller
    end

    def format_path(trail)
      "'" + trail.join("'=>'") + "'"
    end
  end
end
