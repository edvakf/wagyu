require "test_helper"

class WagyuTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wagyu::VERSION
  end
end
