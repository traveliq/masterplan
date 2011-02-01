module Test
  module Unit
    module Assertions
      def assert_masterplan(scheme, compare_to)
        Masterplan.compare(:scheme => scheme, :to => compare_to)
      end
    end
  end
end
