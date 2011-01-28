module Test
  module Unit
    module Assertions
      def assert_schemer(scheme, compare_to)
        Schemer.compare(:scheme => scheme, :to => compare_to)
      end
    end
  end
end
