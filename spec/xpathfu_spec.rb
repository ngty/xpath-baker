require File.join(File.dirname(__FILE__), 'spec_helper')

describe "XPathFu" do

  describe '> default configuration' do

    should 'have :match_casing as true' do
      XPathFu.configure {|config| config.match_casing.should.be.true }
    end

    should 'have :match_ordering as true' do
      XPathFu.configure {|config| config.match_ordering.should.be.true }
    end

    should 'have :match_inner_text as true' do
      XPathFu.configure {|config| config.match_inner_text.should.be.true }
    end

  end

  describe '> configuring' do

    should 'be able to change :match_casing' do
      XPathFu.configure do |config|
        config.match_casing = false
        config.match_casing.should.be.false
        config.match_casing = true
        config.match_casing.should.be.true
      end
    end

    should 'be able to change :match_ordering' do
      XPathFu.configure do |config|
        config.match_ordering = false
        config.match_ordering.should.be.false
        config.match_ordering = true
        config.match_ordering.should.be.true
      end
    end

    should 'be able to change :match_inner_text' do
      XPathFu.configure do |config|
        config.match_inner_text = false
        config.match_inner_text.should.be.false
        config.match_inner_text = true
        config.match_inner_text.should.be.true
      end
    end

  end

end
