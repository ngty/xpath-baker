shared 'has generic :match_attrs_hash support' do

  describe '> no match attrs specified' do
    should "return default scoped path when no scope is specified" do
      XPF.send(@element).should.equal "//#{@element}"
      xpf(@element).should.equal "//#{@element}"
    end
    should "return custom scoped path when scope is specified" do
      scope = '/super/self::'
      XPF.send(@element, scope).should.equal "#{scope}#{@element}"
      xpf(@element, scope).should.equal "#{scope}#{@element}"
    end
  end

  shared 'setting up for {:attr1 => val1, ...}' do
    before do
      @contents = lambda do |path|
        Nokogiri::HTML(%\
          <html>
            <body>
              <#{@element} id="anDriod " class=" gReen" >AG</#{@element}>
              <#{@element} id="BoNobo " class=" Red" >BR</#{@element}>
              <#{@element} id="Conky " class=" bluE" >CB</#{@element}>
              <#{@element} id="dhcPcd" class="bluE" >DB</#{@element}>
            </body>
          </html>
        \).xpath(path).map(&:text)
      end
    end
  end

  shared 'scoping for {:attr1 => val1, ...}' do
    before { @condition = lambda {|k, v| %\normalize-space(@#{k})="#{v}"\ } }
    should "return scoped path w attrs value matching chars casing & with space normalized" do
      attrs = {:id => 'super', :class => 'duper'}
      expected = "#{@scope || '//'}#{@element}[%s]" % attrs.map {|k,v| @condition[k,v] }.join('][')
      XPF.send(@element, *@args[attrs]).should.equal expected
      xpf(@element, *@args[attrs]).should.equal expected
    end
  end

  shared 'matching for {:attr1 => val1, ...}' do
    should "return path that matches nodes w attrs matching chars casing & with space normalized" do
      expected, attrs = ['BR'], {:id => 'BoNobo', :class => 'Red'}
      @contents[XPF.send(@element, *@args[attrs])].should.equal expected
      @contents[xpf(@element, *@args[attrs])].should.equal expected
    end
    should "return path that does not match nodes due to normalized space" do
      attrs = {:id => 'BoNobo ', :class => ' Red'}
      @contents[XPF.send(@element, *@args[attrs])].should.be.empty
      @contents[xpf(@element, *@args[attrs])].should.be.empty
    end
    should "return path that does not match nodes due to chars casing" do
      attrs = {:id => 'bonobo', :class => 'red'}
      @contents[XPF.send(@element, *@args[attrs])].should.be.empty
      @contents[xpf(@element, *@args[attrs])].should.be.empty
    end
  end

  {'default' => nil, 'custom valid' => '//body/'}.each do |mode, scope|

    describe "> #{mode} scoping for {:attr1 => val1, ... }" do
      before do
        @scope = scope
        @args = lambda {|attrs| [@scope, attrs].compact }
      end
      behaves_like 'setting up for {:attr1 => val1, ...}'
      behaves_like 'scoping for {:attr1 => val1, ...}'
      behaves_like 'matching for {:attr1 => val1, ...}'
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:case_sensitive => true}" do
      before do
        @scope = scope
        @args = lambda {|attrs| [@scope, *[attrs, {:case_sensitive => true}]].compact }
      end
      behaves_like 'setting up for {:attr1 => val1, ...}'
      behaves_like 'scoping for {:attr1 => val1, ...}'
      behaves_like 'matching for {:attr1 => val1, ...}'
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:normalize_space => true}" do
      before do
        @scope = scope
        @args = lambda {|attrs| [@scope, *[attrs, {:normalize_space => true}]].compact }
      end
      behaves_like 'setting up for {:attr1 => val1, ...}'
      behaves_like 'scoping for {:attr1 => val1, ...}'
      behaves_like 'matching for {:attr1 => val1, ...}'
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:case_sensitive => false}" do
      behaves_like 'setting up for {:attr1 => val1, ...}'
      before do
        @scope, @attrs = scope, {:id => 'bonobo', :class => 'red'}
        @args = lambda { [@scope, @attrs, {:case_sensitive => false}].compact }
        # Path building helpers
        upper_chars, lower_chars = ['A'..'Z', 'a'..'z'].map {|r| r.to_a.join('') }
        translate = lambda {|s| %\translate(#{s},"#{upper_chars}","#{lower_chars}")\ }
        @condition = lambda {|k, v| %\#{translate["normalize-space(@#{k})"]}=#{translate[%\"#{v}"\]}\ }
      end
      should "return scoped path ignoring chars casing" do
        expected = "#{@scope || '//'}#{@element}[%s]" % @attrs.map {|k,v| @condition[k,v] }.join('][')
        XPF.send(@element, *@args[]).should.equal expected
        xpf(@element, *@args[]).should.equal expected
      end
      should "return path that matches nodes" do
        expected = ['BR']
        @contents[XPF.send(@element, *@args[])].should.equal expected
        @contents[xpf(@element, *@args[])].should.equal expected
      end
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:normalize_space => false}" do
      behaves_like 'setting up for {:attr1 => val1, ...}'
      before do
        @scope, @attrs = scope, {:id => 'BoNobo ', :class => ' Red'}
        @args = lambda { [@scope, @attrs, {:normalize_space => false}].compact }
        @condition = lambda {|k, v| %\@#{k}="#{v}"\ }
      end
      should "return scoped path not normalizing space" do
        expected = "#{@scope || '//'}#{@element}[%s]" % @attrs.map {|k,v| @condition[k,v] }.join('][')
        XPF.send(@element, *@args[]).should.equal expected
        xpf(@element, *@args[]).should.equal expected
      end
      should "return path that matches nodes" do
        expected = ['BR']
        @contents[XPF.send(@element, *@args[])].should.equal expected
        @contents[xpf(@element, *@args[])].should.equal expected
      end
    end

    describe "> #{mode} scoping for {:attr1 => val1, ...} & {:position => 2}" do
      behaves_like 'setting up for {:attr1 => val1, ...}'
      before do
        @scope, @attrs = scope, {:class => 'bluE'}
        @args = lambda { [@scope, @attrs, {:position => 2}].compact }
        @condition = lambda {|k, v| %\normalize-space(@#{k})="#{v}"\ }
      end
      should "return scoped path with specified position" do
        expected = "#{@scope || '//'}#{@element}[%s][2]" % @attrs.map {|k,v| @condition[k,v] }.join('][')
        XPF.send(@element, *@args[]).should.equal expected
        xpf(@element, *@args[]).should.equal expected
      end
      should "return path that matches nodes" do
        expected = ['DB']
        @contents[XPF.send(@element, *@args[])].should.equal expected
        @contents[xpf(@element, *@args[])].should.equal expected
      end
    end

  end

end
