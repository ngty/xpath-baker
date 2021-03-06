require File.join(File.dirname(__FILE__), 'basic_element_shared_data')

shared 'a basic element' do

  before do
    @global_configure = lambda do |settings|
      XPathBaker.configure do |config|
        default_config.merge(settings).each {|k,v| config.send(:"#{k}=",v) }
      end
    end
  end

  after do
    XPathBaker.configure(:reset)
  end

  [single_match_attrs_args, multiple_match_attrs_args].flatten(1).
    each do |(debug, get_ids, match_attrs, config, expected)|

      args = config.empty? ? match_attrs : (match_attrs + [config])

      describe "> match attrs as %s, & %s [#%s]" % [
          match_attrs.map(&:inspect).join(' & '),
          config.empty? ? "no common config" : "common config as #{config.inspect}",
          debug
        ] do

        before do
          @global_configure[{}]
        end

        should "return xpath as described" do
          each_baker do |x|
            x.send(@element, *args).should.equal(expected[@element,0])
          end
        end

        should "return xpath that match intended node(s)" do
          each_baker do |x|
            get_ids[@element, x.send(@element, *args)].should.equal(expected[@element,1])
          end
        end

      end
    end

  no_match_attrs_args.each do |debug, get_ids, config, expected|

    if config.is_a?(Hash)
      describe "> no match attrs nor config specified (w global config as #{config.inspect}) (##{debug})" do

        should "return xpath as described" do
          @global_configure[config]
          each_baker {|x| x.send(@element).should.equal(expected[@element,0]) }
        end

        should "return xpath that match intended node(s)" do
          @global_configure[config]
          each_baker{|x| get_ids[@element, x.send(@element)].should.equal(expected[@element,1]) }
        end

      end
    end

    describe "> only common config specified as #{config.inspect} (##{debug})" do

      before do
        @global_configure[{
          :greedy => !(config.is_a?(Hash) ? config[:greedy] : config.include?('g')),
          :scope => '//awe/some/',
          :position => 9,
        }]
      end

      should "return xpath as described" do
        each_baker {|x| x.send(@element, config).should.equal(expected[@element,0]) }
      end

      should "return xpath that match intended node(s)" do
        each_baker do |x|
          get_ids[@element, x.send(@element, config)].should.equal(expected[@element,1])
        end
      end

    end

  end

end
