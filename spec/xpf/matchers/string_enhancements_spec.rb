require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe "XPF::Matchers::Enhancements::String" do

  describe '> applying check for token' do
    should 'return fragment of xpath that checks for presence of token' do
      'awe'.extend(XPF::Matchers::Enhancements::String).apply_check_for_token('"some"').
        should.equal('(%s)' % [
          %|awe="some"|,
          %|contains(awe,concat(" ","some"," "))|,
          %|starts-with(awe,concat("some"," "))|,
          %|substring(awe,string-length(awe)+1-string-length(concat(" ","some")))=concat(" ","some")|,
      ].join(' or '))
    end
  end

end
