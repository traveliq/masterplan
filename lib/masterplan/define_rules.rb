module Masterplan

  # Include this module into whatever code generates Masterplan::Documents - you get
  # methods that make it easier to generate Masterplan::Rule objects.
  module DefineRules

    # This turns the supplied +example_value+ (any object) into an object that carries rules about itself with it.
    # The rules will be applied when a template is compared with assert_masterplan. Rules are:
    # (default): This always applies - the value must be of the same class as the +example_value+
    # 'allow_nil': This allows the value to be nil (breaking the first rule)
    # 'included_in': Pass an array of values - the value must be one of these
    # 'matches': Pass a regexp - the value must match it, and be a String
    def rule(example_value, options = {})
      Rule.new(example_value, options)
    end

    #for iterating over each example in an array intead of using only the first to compare the data array with
    def iterating_rule(example_value, options = {})
      if example_value
        Rule.new(example_value, :compare_each => true) 
      end
    end

  end

end
