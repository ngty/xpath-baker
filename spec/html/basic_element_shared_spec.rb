require File.join(File.dirname(__FILE__), 'basic_element_shared_data')

shared 'a basic html element' do

  before do
    @xpf_global_configure = lambda do |settings|
      XPF.configure do |config|
        xpf_default_config.merge(settings).each {|k,v| config.send(:"#{k}=",v) }
      end
    end
  end

  after do
    XPF.configure(:reset)
  end

  xpf_no_match_attrs_args.each do |working_args, expected_args|

    contents, ignored_config, config = working_args

    describe "> no match attrs nor config specified (w global config as #{config.inspect})" do

      should "return xpath as described" do
        @xpf_global_configure[config]
        each_xpf {|x| x.send(@element).should.equal(expected_args[@element][0]) }
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        true.should.be.true
        ignored_config.each do |setting, vals|
          vals.each do |val|
            @xpf_global_configure[config.merge(setting => val)]
            each_xpf {|x| x.send(@element).should.equal(expected_args[@element][0]) }
          end
        end
      end

      should "return xpath that match intended node(s)" do
        @xpf_global_configure[config]
        each_xpf do |x|
          contents[@element, x.send(@element)].should.equal(expected_args[@element][1])
        end
      end

    end

    describe "> only config specified as #{config.inspect}" do

      before { @xpf_global_configure[{:scope => '/html//', :position => 9}] }

      should "return xpath as described" do
        each_xpf {|x| x.send(@element, config).should.equal(expected_args[@element][0]) }
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        ignored_config.each do |setting, vals|
          vals.each do |val|
            each_xpf do |x|
              x.send(@element, config.merge(setting => val)).should.equal(expected_args[@element][0])
            end
          end
        end
      end

      should "return xpath that match intended node(s)" do
        each_xpf do |x|
          contents[@element, x.send(@element, config)].should.equal(expected_args[@element][1])
        end
      end

    end

  end

  xpf_single_match_attrs_generic_args.each do |working_args, expected_args|

    contents, ignored_config, alternative_config, line, match_attrs, config = working_args

    describe "> match attrs as #{match_attrs.inspect} w global config as #{config.inspect} [##{line}]" do

      should "return xpath as described" do
        @xpf_global_configure[config]
        each_xpf {|x| x.send(@element, match_attrs).should.equal(expected_args[@element][0]) }
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        true.should.be.true
        ignored_config.each do |setting, vals|
          vals.each do |val|
            @xpf_global_configure[config.merge(setting => val)]
            each_xpf do |x|
              x.send(@element, match_attrs).should.equal(expected_args[@element][0])
            end
          end
        end
      end

      should "return xpath that match intended node(s)" do
        @xpf_global_configure[config]
        each_xpf do |x|
          contents[@element, x.send(@element, match_attrs)].should.equal(expected_args[@element][1])
        end
      end

    end

    describe "> match attrs as #{match_attrs.inspect} w common config as #{config.inspect} [##{line}]" do

      before do
        @xpf_global_configure[
          config.inject({}) do |memo, (key, val)|
            memo.merge(key => alternative_config[key][val])
          end
        ]
      end

      should "return xpath as described" do
        each_xpf {|x| x.send(@element, match_attrs, config).should.equal(expected_args[@element][0]) }
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        true.should.be.true
        ignored_config.each do |setting, vals|
          vals.each do |val|
            each_xpf do |x|
              x.send(@element, match_attrs, config).should.equal(expected_args[@element][0])
            end
          end
        end
      end

      should "return xpath that match intended node(s)" do
        each_xpf do |x|
          contents[@element, x.send(@element, match_attrs, config)].should.equal(expected_args[@element][1])
        end
      end

    end

    next if config.keys.any?{|key| [:position, :scope, :greedy].include?(key) }

    describe "> match attrs as #{match_attrs.inspect} w per-match-attr config as #{config.inspect} [##{line}]" do

      before do
        @other_config = config.inject({}) {|memo, (key, val)| memo.merge(key => alternative_config[key][val]) }
      end

      should "return xpath as described" do
        each_xpf do |x|
          x.send(@element, [match_attrs, config], @other_config).
            should.equal(expected_args[@element][0])
        end
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        true.should.be.true
        ignored_config.each do |setting, vals|
          vals.each do |val|
            each_xpf do |x|
              x.send(@element, [match_attrs, config], @other_config).
                should.equal(expected_args[@element][0])
            end
          end
        end
      end

      should "return xpath that match intended node(s)" do
        each_xpf do |x|
          contents[@element, x.send(@element, [match_attrs, config], @other_config)].
            should.equal(expected_args[@element][1])
        end
      end

    end

  end

  xpf_single_match_attrs_non_generic_args.each do |working_args, expected_args|

    contents, ignored_config, line, match_attrs, config, other_config = working_args

    describe "> match attrs as %s w per-match-attrs as %s & global config as %s [#%s]" % [
        match_attrs.inspect, config.inspect, other_config.inspect, line
      ] do

      before { @xpf_global_configure[other_config] }

      should "return xpath as described" do
        each_xpf {|x| x.send(@element, [match_attrs, config]).should.equal(expected_args[@element][0]) }
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        true.should.be.true
        ignored_config.each do |setting, vals|
          vals.each do |val|
            each_xpf do |x|
              x.send(@element, [match_attrs, config]).should.equal(expected_args[@element][0])
            end
          end
        end
      end

      should "return xpath that match intended node(s)" do
        each_xpf do |x|
          contents[@element, x.send(@element, [match_attrs, config])].should.equal(expected_args[@element][1])
        end
      end

    end

    describe "> match attrs as %s w per-match-attrs as %s & common config as %s [#%s]" % [
        match_attrs.inspect, config.inspect, other_config.inspect, line
      ] do

      should "return xpath as described" do
        each_xpf do |x|
          x.send(@element, [match_attrs, config], other_config).
            should.equal(expected_args[@element][0])
        end
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        true.should.be.true
        ignored_config.each do |setting, vals|
          vals.each do |val|
            each_xpf do |x|
              x.send(@element, [match_attrs, config], other_config).
                should.equal(expected_args[@element][0])
            end
          end
        end
      end

      should "return xpath that match intended node(s)" do
        each_xpf do |x|
          contents[@element, x.send(@element, [match_attrs, config], other_config)].
            should.equal(expected_args[@element][1])
        end
      end

    end

  end

  xpf_multiple_match_attrs_args.each do |(contents, line, match_attrs, config), expected_args|

    args = [match_attrs, config].flatten(1)

    describe "> match attrs as %s, & w common config as %s [#%s]" % [
        match_attrs.map(&:inspect).join(' & '), config.inspect, line
      ] do

      should "return xpath as described" do
        each_xpf do |x|
          x.send(@element, *args).should.equal(expected_args[@element][0])
        end
      end

      should "return xpath that match intended node(s)" do
        each_xpf do |x|
          contents[@element, x.send(@element, *args)].should.equal(expected_args[@element][1])
        end
      end

    end

  end

end
