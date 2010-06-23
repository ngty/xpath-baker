module XPF

  class ConfigSettingNotSupportedError < Exception ; end
  class InvalidConfigSettingValueError < Exception ; end

  ###
  # Generated xpaths are affected by the following configurable settings:
  #
  # 1). *case_sensitive* affects matching of chars not in the same casing:
  #
  #   <B>KungFu</B>
  #
  # <table>
  # <tr>
  # <th>Option</th>
  # <th>XPath Fragment</th>
  # <th>Matching Text(s)</th>
  # <th>Default?</th>
  # </tr>
  # <tr>
  # <td>true</td>
  # <td>?B[text()='?']</td>
  # <td>'KungFu'</td>
  # <td>yes</td>
  # </tr>
  # <tr>
  # <td>false</td>
  # <td>?B[translate(text(),'A~Z','a~z')=translate('?','A~Z','a~z')]</td>
  # <td>'KungFu', 'KUNGFU', 'kungfu'</td>
  # <td>no</td>
  # </tr>
  # </table>
  #
  # Note: The above 'A~Z' & 'a~z' are just abbreviated expressions of
  # 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' & 'abcdefghijklmnopqrstuvwxyz'.
  #
  # 2). *normalize_space* affects the trimming of spaces (stripping leading & trailing
  # whitespace & replacing sequences of whitespace chars by a single space):
  #
  #   <B> kung  fu</B>
  #
  # <table>
  # <tr>
  # <th>Option</th>
  # <th>XPath Fragment</th>
  # <th>Matching Text(s)</th>
  # <th>Default?</th>
  # </tr>
  # <tr>
  # <td>true</td>
  # <td>?B[normalize-space(text())='?']</td>
  # <td>'kung fu'</td>
  # <td>yes</td>
  # </tr>
  # <tr>
  # <td>false</td>
  # <td>?B[text()='?']</td>
  # <td>' kung  fu'</td>
  # <td>no</td>
  # </tr>
  # </table>
  #
  # 3). *include_inner_text* affects whether matching is done for direct text or full
  # inner text.
  #
  #   <B>kung<I/>fu</I></B>
  #
  # <table>
  # <tr>
  # <th>Option</th>
  # <th>XPath Fragment</th>
  # <th>Matching Text(s)</th>
  # <th>Default?</th>
  # </tr>
  # <tr>
  # <td>true</td>
  # <td>?B[.='?']</td>
  # <td>'kungfu'</td>
  # <td>yes</td>
  # </tr>
  # <tr>
  # <td>false</td>
  # <td>?B[text()='?']</td>
  # <td>'kung'</td>
  # <td>no</td>
  # </tr>
  # </table>
  #
  # 4). *position* affects whether matching is done for all nodes or just the nth:
  #
  #   <B>kungfu 1</B> <!-- position 1 -->
  #   <B>kungfu 2</B> <!-- position 2 -->
  #   <B>kungfu 3</B> <!-- position 3 -->
  #
  # <table>
  # <tr>
  # <th>Option</th>
  # <th>XPath Fragment</th>
  # <th>Default?</th>
  # </tr>
  # <tr>
  # <td>nil</td>
  # <td>?B</td>
  # <td>yes</td>
  # </tr>
  # <tr>
  # <td>any non-zero int (eg. 2)</td>
  # <td>?B[2]</td>
  # <td>no</td>
  # </tr>
  # </table>
  #
  # TODO: This part needs to be updated !!
  # 5). *axial_node* specifies the matched node-set w.r.t the current reference node:
  #
  # <table>
  # <tr>
  # <th>Option</th>
  # <th>Default?</th>
  # </tr>
  # <tr>
  # <td>:ancestor</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:ancestor_or_self</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:child</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:descendant</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:descendant_or_self</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:following</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:following_sibling</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:parent</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:preceding</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:preceding_sibling</td>
  # <td>no</td>
  # </tr>
  # <tr>
  # <td>:self</td>
  # <td>yes</td>
  # </tr>
  # </table>
  #
  # A good explanation of xpath axes can be found at www.xmlplease.com/axis
  #
  # 6). *match_ordering* is currently only useful where a path is built using
  # nested elements info (eg. TR & TD, UL/OL & LI).
  #
  # Example 1: The following will build an xpath using axis :following_sibling
  # to ensure TR contains TDs with cell2 appearing only after cell1, & cell3
  # appearing only after cell2.
  #
  #   xpf.tr({:cells => %w{cell1 cell2 cell3}, :match_ordering => true)
  #
  # Example 2: The following will build an xpath that only ensures TR has TDs
  # that contain cell1, cell2 & cell3, ignoring the order of appearance.
  #
  #   xpf.tr({:cells => %w{cell1 cell2 cell3}, :match_ordering => false)
  #
  # Note: The default value if true.
  #
  class Configuration

    # %w{!g !c !o !n !i s
    #'ng,nc,no,nn,ni,>1^,1~7$,<=8^,
    # %w{ng nc no nn ni 1~7$}
    # %w{g c o n i 1~7$ descendant-or-self::a //body/watever XPF::Matchers::Attribute XPF::Matchers::Text}
    DEFAULT_SETTINGS = {
      :greedy             => true,       # g, !g
      :case_sensitive     => true,       # c, !c
      :match_ordering     => true,       # o, !o
      :normalize_space    => true,       # n, !n
      :include_inner_text => true,       # i, !i
      :scope              => '//',       # //some/thing
      :position           => nil,        # 1~7$, 1~8^, 1^, 7$, >=9$, <=9^
      :axial_node         => 'self::*',  # descendant-or-self::a, descendant_or_self::a
      :element_matcher    => XPF::Matchers::Element,
      :attribute_matcher  => XPF::Matchers::Attribute,
      :text_matcher       => XPF::Matchers::Text,
      :any_text_matcher   => XPF::Matchers::AnyText,
      :literal_matcher    => XPF::Matchers::Literal,
      :group_matcher      => XPF::Matchers::Group,
    }

    SETTING_MAPPERS = { #:nodoc:
      :simple => {
         'g' => {:greedy => true},
        '!g' => {:greedy => false},
         'c' => {:case_sensitive => true},
        '!c' => {:case_sensitive => false},
         'o' => {:match_ordering => true},
        '!o' => {:match_ordering => false},
         'n' => {:normalize_space => true},
        '!n' => {:normalize_space => false},
         'i' => {:include_inner_text => true},
        '!i' => {:include_inner_text => false},
      },
      :regexp => {
        /::Element$/   => lambda{|klass| {:element_matcher => classify(klass)} },
        /::Attribute$/ => lambda{|klass| {:attribute_matcher => classify(klass)} },
        /::Text$/      => lambda{|klass| {:text_matcher => classify(klass)} },
        /::AnyText$/   => lambda{|klass| {:any_text_matcher => classify(klass)} },
        /::Literal$/   => lambda{|klass| {:literal_matcher => classify(klass)} },
        /::Group$/     => lambda{|klass| {:group_matcher => classify(klass)} }
      },
      :test_fail => {
        :Scope     => lambda{|val| {:scope => val} },
        :AxialNode => lambda{|val| {:axial_node => val} },
        :Position  => lambda{|val| {:position => val} },
      }
    }

    SETTING_VALIDATORS = { #:nodoc:
      :greedy             => :is_boolean!,
      :case_sensitive     => :is_boolean!,
      :match_ordering     => :is_boolean!,
      :normalize_space    => :is_boolean!,
      :include_inner_text => :is_boolean!,
    }

    class << self

      DEFAULT_SETTINGS.keys.each do |setting|

        attr_accessor setting

        if SETTING_VALIDATORS[setting] == :is_boolean!
          alias_method :"#{setting}?", setting if SETTING_VALIDATORS[setting] == :is_boolean!
        end

        define_method(:"#{setting}=") do |val|
          (validator = SETTING_VALIDATORS[setting]) && send(validator, setting, val)
          instance_variable_set(:"@#{setting}", val)
        end

      end

      ###
      # Reset settings to default, as declared by DEFAULT_SETTINGS.
      #
      def reset(&blk)
        DEFAULT_SETTINGS.each {|setting, val| send(:"#{setting}=", val) }
        block_given? && yield(self)
      end

      ###
      # TODO: Update !!
      # Duplicates a copy of Configuration, further customized by +settings+ hash.
      #
      # Raises:
      # * ConfigSettingNotSupportedError if any of the setting is not supported
      # * InvalidConfigSettingValueError if any setting value is invalid
      #
      def new(settings)
        case settings
        when Hash then new_from_hash(settings)
        when Array then new_from_array(settings)
        else raise InvalidArgumentError.new('Initializing new configuration requires an Array/Hash !!')
        end
      end

      ###
      # Returns configured settings as a hash.
      #
      def to_hash
        DEFAULT_SETTINGS.keys.inject({}) do |memo, setting|
          memo.merge(setting => send(setting))
        end
      end

      # TODO: Add DOC
      def describes_config?(something)
        begin
          case something
          when Hash then (something.keys - DEFAULT_SETTINGS.keys).empty?
          when Array then new_from_array(something, true) && true
          else false
          end
        rescue InvalidArgumentError, InvalidConfigSettingValueError
          false
        end
      end

      # TODO: Add DOC
      def axial_node=(expr)
        @axial_node = AxialNode.convert(expr.to_s)
      end

      # TODO: Add DOC
      def position=(expr)
        @position = Position.convert(expr.to_s)
      end

      # TODO: Add DOC
      def scope=(expr)
        @scope = Scope.convert(expr.to_s)
      end

      # TODO: Add DOC
      def normalize(settings)
        case settings
        when Array
          raise_err = lambda do |val|
            raise InvalidConfigSettingValueError.new \
              "Config setting value '#{val}' cannot be mapped to any supported settings !!"
          end
          settings.inject({}) do |memo, val|
            memo.merge(simple_mapping(val) || regexp_mapping(val) || test_fail_mapping(val) || raise_err[val])
          end
        when Hash then settings
        else raise InvalidArgumentError.new('Config normalizing can ONLY be done for Array/Hash !!')
        end
      end

      private

        def new_from_hash(settings)
          config = self.dup
          settings.each do |setting, val|
            config.respond_to?(setter = :"#{setting}=") ? config.send(setter, val) :
              raise(ConfigSettingNotSupportedError.new("Config setting :#{setting} is not supported !!"))
          end
          config
        end

        def new_from_array(settings, test_mode = false)
          config = normalize(settings)
          test_mode ? true : new_from_hash(config)
        end

        def simple_mapping(arg)
          SETTING_MAPPERS[:simple][arg]
        end

        def regexp_mapping(arg)
          _, config = SETTING_MAPPERS[:regexp].find{|regexp,_| arg.to_s =~ regexp }
          config && config[arg]
        end

        def test_fail_mapping(arg)
          _, config = SETTING_MAPPERS[:test_fail].find do |klass,config|
            begin
              config[const_get(klass).convert(arg.to_s)]
            rescue InvalidConfigSettingValueError
              nil
            end
          end
          config && config[arg.to_s]
        end

        def is_boolean!(setting, val)
          fail_unless("Config setting :#{setting} must be boolean true/false !!") do
            [true, false].include?(val)
          end
        end

        def fail_unless(msg, error = InvalidConfigSettingValueError)
          yield or raise(error.new(msg))
        end

        def classify(klass)
          klass.is_a?(Class) ? klass :
            klass.to_s.split('::').inject(Object){|src, const| src.const_get(const) }
        end

    end

    private

      module Scope #:nodoc:
        class << self

          ERROR = InvalidConfigSettingValueError.new \
            "Config setting :scope must start & end with '/' !!"

          def convert(str)
            (str.start_with?('/') && str.end_with?('/')) ? str : raise(ERROR)
          end

        end
      end

      module AxialNode #:nodoc:
        class << self

          VALID_VALS = %w{
            ancestor ancestor-or-self attribute child descendant descendant-or-self
            following following-sibling namespace parent preceding preceding-sibling self
          }.map do |val|
            [val.gsub('-','_').to_sym, val, "#{val}::*", /^#{val}::\w+$/]
          end.flatten(1)

          ERROR = InvalidConfigSettingValueError.new(
            'Config setting :axial_node must match any of the following: %s or %s !!' %
              [VALID_VALS[0..-2].join(', '), VALID_VALS[-1]]
          )

          def convert(str)
            frags = str.gsub('_','-').split('::').map(&:strip)
            case expr = ((frags[1] || '').empty? ? [frags[0], '*'] : frags[0..1]).join('::')
            when *VALID_VALS then expr
            else raise ERROR
            end
          end

        end
      end

      module Position #:nodoc:
        class << self

          ERROR = InvalidConfigSettingValueError.new(
            'Config setting :position must match any of the following: %s or %s !!' % [
              '(1) nil or any integer (0 & nil are taken as no position specified)',
              '(2) /^(!)?(>|>=|<|<=)?([1-9]\d*)(\^|\$)?$/'
          ])

          def convert(str)
            negate = str.start_with?('!')
            quote = lambda{|expr| (negate ? '[not(%s)]' : '[%s]') % expr }
            expr = case str
              when '0', '' then nil
              when /^!?([1-9]\d*)[\^\$]?$/ then (negate ? '[position()!=%s]' : '[%s]') % $1
              when /^!?([1-9]\d*)~([1-9]\d*)[\^\$]?$/ then quote['position()>=%s and position()<=%s' % [$1,$2]]
              when /^!?(>|>=|<|<=)([1-9]\d*)[\^\$]?$/ then quote['position()%s%s' % [$1,$2]]
              else raise ERROR
              end
            expr && expr.extend(Extensions).init(str.end_with?('^'))
          end

          module Extensions

            def init(is_start)
              @is_start = is_start
              self
            end

            def start?
              @is_start
            end

            def end?
              !@is_start
            end

          end

        end
      end

  end

  Configuration.reset

end
