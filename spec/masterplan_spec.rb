require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

include Masterplan::DefineRules

describe "Masterplan" do
  before(:each) do
    @scheme = Masterplan::Document.new({
      "ship" => {
        "parts" => [
          {
            "name" => "Mast",
            "length" => rule(12.3, :allow_nil => true),
            "material" => rule("wood", :included_in => ['wood', 'steel', 'human'])
          },
          {
            "name" => "Rudder",
            "length" => nil,
            "material" => "steel"
          }
        ]
      }
    })
  end
  
  describe "Testing with #compare" do

    it "returns true for a valid document, treating symbols and strings alike" do
      Masterplan.compare(
        :scheme => @scheme,
        :to => {
          :ship => {
            :parts => [
              :name => "Thingy",
              :length => 1.0,
              :material => "human"
            ]
          }
        }
      ).should be_true
    end
    it "complains if a key is missing" do
      lambda do
        Masterplan.compare(
          :scheme => @scheme,
          :to => {
            :tank => {}
          }
        )
      end.should raise_error(Masterplan::FailedError, /expected:	ship*\n*received:	tank/)
    end
    it "complains if not given a Masterplan::Document"
    it "complains if there are extra keys"
    it "complains if a value is of the wrong class"
    it "complains if a value is nil"
    it "does not complain if a value is nil and the rule allows nil"
    it "complains if a value does not match the regexp rule"
    it "complains if a value is not included in the rule list"
    it "checks all values of value arrays, but only against the first array value of the scheme"
    it "checks all array values one-to-one if the compare_each rule is used"
  end

  it "convertsinto plain example hashes"
  it "doesn't create a Document out of anything other than a Hash"
  it "checks that the examples of rules obey the rules"
  it "has a unit test extension method"
end
