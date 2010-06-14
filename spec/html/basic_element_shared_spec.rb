require File.join(File.dirname(__FILE__), 'basic_element_shared_data')

shared 'a basic html element' do

  before do
    @xpf_global_configure = lambda do |settings|
      XPF.configure do |config|
        xpf_default_config.merge(settings).each {|k,v| config.send(:"#{k}=",v) }
      end
    end
  end

  xpf_no_match_attrs_args.each do |args, expected_args|

    contents, ignored_config_settings, config = args

    describe "> no match attrs nor config specified (w global config as #{config.inspect})" do

      should "return xpath as described" do
        @xpf_global_configure[config]
        each_xpf {|x| x.send(@element).should.equal(expected_args[@element][0]) }
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        ignored_config_settings.each do |setting, vals|
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
        ignored_config_settings.each do |setting, vals|
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

  xpf_match_attrs_args.each do |args, expected_args|

    contents, ignored_config_settings, match_attrs, config = args

    describe "> match attrs as #{match_attrs.inspect} w global config as #{config.inspect}" do

      should "return xpath as described" do
        @xpf_global_configure[config]
        each_xpf {|x| x.send(@element, match_attrs).should.equal(expected_args[@element][0]) }
      end

      should "always return xpath as described (ignoring changes in other config settings)" do
        ignored_config_settings.each do |setting, vals|
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

#    describe "> match attrs as #{match_attrs.inspect} w common config as #{config.inspect}" do
#
#      before { @xpf_global_configure[{:scope => '/html//', :position => 9}] }
#
#      should "return xpath as described" do
#        @xpf_global_configure[config]
#        each_xpf {|x| x.send(@element, match_attrs).should.equal(args[@element][0]) }
#      end
#
#      should "always return xpath as described (ignoring changes in other config settings)" do
#        ignored_config_settings.each do |setting, vals|
#          vals.each do |val|
#            @xpf_global_configure[config.merge(setting => val)]
#            each_xpf do |x|
#              x.send(@element, match_attrs).should.equal(args[@element][0])
#            end
#          end
#        end
#      end
#
#      should "return xpath that match intended node(s)" do
#        @xpf_global_configure[config]
#        each_xpf {|x| contents[@element, x.send(@element, match_attrs)].should.equal(args[@element][1]) }
#      end
#
#    end

  end

#    describe "> match attrs as #{match_attrs.inspect} w common match attrs config as #{config.inspect}" do
#
#    end
#
#    describe "> match attrs as #{match_attrs.inspect} w per match attrs config as #{config.inspect}" do
#
#    end
#
#  end





#  shared 'setting up for {:attr1 => val1, ...}' do
#    before do
#      @contents = lambda do |path|
#        Nokogiri::HTML(%\
#          <html>
#            <body>
#              <#{@element} id="anDriod " class=" gReen" >AG</#{@element}>
#              <#{@element} id="BoNobo " class=" Red" >BR</#{@element}>
#              <#{@element} id="Conky " class=" bluE" >CB</#{@element}>
#              <#{@element} id="dhcPcd" class="bluE" >DB</#{@element}>
#            </body>
#          </html>
#        \).xpath(path).map(&:text)
#      end
#
#    end
#  end
#
#  shared 'scoping for {:attr1 => val1, ...}' do
#    before do
#      @condition = lambda {|k, v| %\normalize-space(@#{k})="#{v}"\ }
#    end
#    should "return scoped path w attrs value matching chars casing & with space normalized" do
#      each_xpf do |x|
#        attrs = {:id => 'super', :class => 'duper'}
#        expected = "#{@scope || '//'}#{@element}[%s]" % attrs.map {|k,v| @condition[k,v] }.join('][')
#        x.send(@element, *@args[attrs]).should.equal expected
#      end
#    end
#  end
#
#  shared 'matching for {:attr1 => val1, ...}' do
#    should "return path that matches nodes w attrs matching chars casing & with space normalized" do
#      each_xpf do |x|
#        expected, attrs = ['BR'], {:id => 'BoNobo', :class => 'Red'}
#        @contents[x.send(@element, *@args[attrs])].should.equal expected
#      end
#    end
#    should "return path that does not match nodes due to normalized space" do
#      each_xpf do |x|
#        attrs = {:id => 'BoNobo ', :class => ' Red'}
#        @contents[x.send(@element, *@args[attrs])].should.be.empty
#      end
#    end
#    should "return path that does not match nodes due to chars casing" do
#      each_xpf do |x|
#        attrs = {:id => 'bonobo', :class => 'red'}
#        @contents[x.send(@element, *@args[attrs])].should.be.empty
#      end
#    end
#  end
#
#  {'default' => nil, 'custom valid' => '//body/'}.each do |mode, scope|
#
#    describe "> #{mode} scoping for {:attr1 => val1, ... }" do
#      before do
#        @scope = scope
#        @args = lambda {|attrs| [attrs, scoped_config(@scope, {})] }
#      end
#      behaves_like 'setting up for {:attr1 => val1, ...}'
#      behaves_like 'scoping for {:attr1 => val1, ...}'
#      behaves_like 'matching for {:attr1 => val1, ...}'
#    end
#
#    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:case_sensitive => true}" do
#      before do
#        @scope = scope
#        @args = lambda {|attrs| [attrs, scoped_config(@scope, :case_sensitive => true)] }
#      end
#      behaves_like 'setting up for {:attr1 => val1, ...}'
#      behaves_like 'scoping for {:attr1 => val1, ...}'
#      behaves_like 'matching for {:attr1 => val1, ...}'
#    end
#
#    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:normalize_space => true}" do
#      before do
#        @scope = scope
#        @args = lambda {|attrs| [attrs, scoped_config(@scope, :normalize_space => true)] }
#      end
#      behaves_like 'setting up for {:attr1 => val1, ...}'
#      behaves_like 'scoping for {:attr1 => val1, ...}'
#      behaves_like 'matching for {:attr1 => val1, ...}'
#    end
#
#    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:case_sensitive => false}" do
#      behaves_like 'setting up for {:attr1 => val1, ...}'
#      before do
#        @scope, @attrs = scope, {:id => 'bonobo', :class => 'red'}
#        @args = lambda { [@attrs, scoped_config(@scope, :case_sensitive => false)] }
#        # Path building helpers
#        upper_chars, lower_chars = ['A'..'Z', 'a'..'z'].map {|r| r.to_a.join('') }
#        translate = lambda {|s| %\translate(#{s},"#{upper_chars}","#{lower_chars}")\ }
#        @condition = lambda {|k, v| %\#{translate["normalize-space(@#{k})"]}=#{translate[%\"#{v}"\]}\ }
#      end
#      should "return scoped path ignoring chars casing" do
#        each_xpf do |x|
#          expected = "#{@scope || '//'}#{@element}[%s]" % @attrs.map {|k,v| @condition[k,v] }.join('][')
#          x.send(@element, *@args[]).should.equal expected
#        end
#      end
#      should "return path that matches nodes" do
#        each_xpf do |x|
#          expected = %w{BR}
#          @contents[x.send(@element, *@args[])].should.equal expected
#        end
#      end
#    end
#
#    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:normalize_space => false}" do
#      behaves_like 'setting up for {:attr1 => val1, ...}'
#      before do
#        @scope, @attrs = scope, {:id => 'BoNobo ', :class => ' Red'}
#        @args = lambda { [@attrs, scoped_config(@scope, :normalize_space => false)] }
#        @condition = lambda {|k, v| %\@#{k}="#{v}"\ }
#      end
#      should "return scoped path not normalizing space" do
#        each_xpf do |x|
#          expected = "#{@scope || '//'}#{@element}[%s]" % @attrs.map {|k,v| @condition[k,v] }.join('][')
#          o.send(@element, *@args[]).should.equal expected
#        end
#      end
#      should "return path that matches nodes" do
#        each_xpf do |x|
#          expected = %w{BR}
#          @contents[x.send(@element, *@args[])].should.equal expected
#        end
#      end
#    end
#
#    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:position => 2}" do
#      behaves_like 'setting up for {:attr1 => val1, ...}'
#      before do
#        @scope, @attrs = scope, {:class => 'bluE'}
#        @args = lambda { [@attrs, scoped_config(@scope, :position => 2)] }
#        @condition = lambda {|k, v| %\normalize-space(@#{k})="#{v}"\ }
#      end
#      should "return scoped path with specified position" do
#        each_xpf do |x|
#          expected = "#{@scope || '//'}#{@element}[%s][2]" % @attrs.map {|k,v| @condition[k,v] }.join('][')
#          x.send(@element, *@args[]).should.equal expected
#        end
#      end
#      should "return path that matches nodes" do
#        each_xpf do |x|
#          expected = %w{DB}
#          @contents[x.send(@element, *@args[])].should.equal expected
#        end
#      end
#    end
#
#  end

end
