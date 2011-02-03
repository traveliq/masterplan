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
            "material" => rule("wood", :included_in => ['wood', 'steel', 'human']),
            "scream" => rule("AAAAAAH", :matches => /[A-Z]/),
          },
          {
            "name" => "Rudder",
            "length" => nil,
            "material" => "steel",
            "scream" => "HAAAAAARGH"
          }
        ]
      }
    })
  end

  def test_value_and_expect(testee, *error_and_descripton)
    lambda do
      Masterplan.compare(
        :scheme => @scheme,
        :to => testee
      )
    end.should raise_error(*error_and_descripton)
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
              :material => "human",
              :scream => "UUUUUUUUH"
            ]
          }
        }
      ).should be_true
    end

    it "complains if a key is missing" do
      test_value_and_expect(
        { :tank => {} },
        Masterplan::FailedError, /expected:	ship*\n*received:	tank/
      )
    end

    it "complains if not given a Masterplan::Document" do
      lambda do
        Masterplan.compare(
          :scheme => {},
          :to => {}
        )
      end.should raise_error(ArgumentError, /scheme needs to be a Masterplan::Document/)
    end

    it "complains if there are extra keys" do
      test_value_and_expect(
        { :ship => {}, :boat => {} },
        Masterplan::FailedError, /expected:	ship*\n*received:	boat,ship/
      )
    end
    
    it "complains if a value is of the wrong class" do
      test_value_and_expect(
        { :ship => [] },
        Masterplan::FailedError, /value at 'root'=>'ship' \(Array\) is not a Hash/
      )
    end

    it "complains if a value is nil" do
      test_value_and_expect(
        { :ship => {:parts => [{:name => nil, :length => 1.0, :material => "wood", :scream => "BLEEEEERGH"}]} },
        Masterplan::FailedError, /value at 'root'=>'ship'=>'parts'=>'0'=>'name' \(NilClass\) is not a String/
      )
    end

    it "does not complain if a value is nil and the rule allows nil" do
      Masterplan.compare(
          :scheme => @scheme,
          :to => { :ship => {:parts => [{:name => "haha", :length => nil, :material => "wood", :scream => "UUUUAUAUAUAH"}]} }
     ).should == true
    end

    it "complains if a value does not match the regexp rule" do
      test_value_and_expect(
        { :ship => {:parts => [{:name => "thing", :length => 1.0, :material => "wood", :scream => "omai !"}]} },
        Masterplan::FailedError, /value at 'root'=>'ship'=>'parts'=>'0'=>'scream' "omai !" \(String\) does not match \/\[A-Z\]\//
      )
    end

    it "complains if a value is not included in the rule list" do
      test_value_and_expect(
        { :ship => {:parts => [{:name => "thing", :length => 1.0, :material => "socks", :scream => "GRAGRAGR"}]} },
        Masterplan::FailedError, /value at 'root'=>'ship'=>'parts'=>'0'=>'material' "socks" \(String\) is not one of \["wood", "steel", "human"\]/
      )
    end

    it "checks all values of value arrays, but only against the first array value of the scheme"
    it "checks all array values one-to-one if the compare_each rule is used"
  end

  it "convertsinto plain example hashes"
  it "doesn't create a Document out of anything other than a Hash"
  it "checks that the examples of rules obey the rules"
  it "has a unit test extension method"
end
