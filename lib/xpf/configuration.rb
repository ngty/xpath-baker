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
  # 5). *axis* specifies the matched node-set w.r.t the current reference node:
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
      :greedy             => true,   # g, !g
      :case_sensitive     => true,   # c, !c
      :match_ordering     => true,   # o, !o
      :normalize_space    => true,   # n, !n
      :include_inner_text => true,   # i, !i
      :scope              => '//',   # //some/thing
      :position           => 0,      # 1~7$, 1~8^, 1^, 7$, >=9$, <=9^
      :axis               => :self,  # descendant-or-self::a, descendant_or_self::a

      # TODO: Add missing tests
      :attribute_matcher  => XPF::Matchers::Attribute,
      :text_matcher       => XPF::Matchers::Text,
      :literal_matcher    => XPF::Matchers::Literal,
      :group_matcher      => XPF::Matchers::Group,
      # :subtag_matcher
    }

    SETTING_TRANSLATORS = {
      '!g' => {:greedy             => false},
      '!n' => {:normalize_space    => false},
      '!c' => {:case_sensitive     => false},
      '!o' => {:match_ordering     => false},
      '!i' => {:include_inner_text => false},

      'g'  => {:greedy             => true},
      'n'  => {:normalize_space    => true},
      'c'  => {:case_sensitive     => true},
      'o'  => {:match_ordering     => true},
      'i'  => {:include_inner_text => true},
    }

    SETTING_VALIDATORS = {
      :greedy             => :is_boolean!,
      :case_sensitive     => :is_boolean!,
      :match_ordering     => :is_boolean!,
      :normalize_space    => :is_boolean!,
      :include_inner_text => :is_boolean!,
      :scope              => nil,

      # TODO: update broken tests
      #:position          => :is_valid_position!,
      # :axis             => :is_valid_axis!,

      # TODO: Add missing tests
      :attribute_matcher  => nil,
      :text_matcher       => nil,
      :literal_matcher    => nil,
      :group_matcher      => nil,
    }

    class << self

      DEFAULT_SETTINGS.keys.each do |setting|

        attr_accessor setting
        alias_method :"#{setting}?", setting

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
      # Duplicates a copy of Configuration, further customized by +settings+ hash.
      #
      # Raises:
      # * ConfigSettingNotSupportedError if any of the setting is not supported
      # * InvalidConfigSettingValueError if any setting value is invalid
      #
      def new(settings)
        config, error = self.dup, ConfigSettingNotSupportedError
        settings.each do |setting, val|
          setter = :"#{setting}="
          fail_unless("Config setting :#{setting} is not supported !!", error) do
            config.respond_to?(setter)
          end
          config.send(setter, val)
        end
        config
      end

      ###
      # Returns configured settings as a hash.
      #
      def to_hash
        DEFAULT_SETTINGS.keys.inject({}) do |memo, setting|
          memo.merge(setting => send(setting))
        end
      end

      def axis=(axis)
        # TODO: Add missing spec !!
        @axis = ((frags = axis.to_s.split('::'))[1] || '').strip.empty? ?
          [frags[0].gsub('_','-'),'*'].join('::') : axis
      end

      def position=(position)
        @position = Position.convert(position.to_s)
      end

      def describes_config?(something)
        # TODO: Add missing spec !!
        case something
        when Hash then (something.keys - DEFAULT_SETTINGS.keys).empty?
        when Array then translate(something) rescue false
        else false
        end
      end

      def translate(args)
        # TODO: Add missing spec !!
        if args.is_a?(Array)
        else
          raise InvalidArgumentError
        end
      end

      private

        def is_boolean!(setting, val)
          fail_unless("Config setting :#{setting} must be boolean true/false !!") do
            [true, false].include?(val)
          end
        end

        def is_valid_position!(setting, val)
          fail_unless("Config setting :#{setting} must be nil or a non-zero integer !!") do
            val.nil? or (val.is_a?(Integer) && val.nonzero?)
          end
        end

        def is_valid_axis!(setting, val)
          axes = ''
          # TODO: This part needs to be updated !! Cos we wanna support:
          # * :ancestor, :ancestor_or_self
          # * 'ancestor', 'ancestor-or-self', ...
          # * 'ancestor::*', 'ancestor-or-self::*'
          #
#          axes = %w{
#            ancestor ancestor_or_self child descendant descendant_or_self following
#            following_sibling namespace parent preceding preceding_sibling self
#          }.map(&:to_sym)
#          msg = "Config setting :#{setting} must be any of :%s & :%s !!" %
#            [axes[0..-2].map(&:to_s).join(', :'), axes[-1]]
#          fail_unless(msg) { axes.include?(val) }
        end

        def fail_unless(msg, error = InvalidConfigSettingValueError)
          yield or raise(error.new(msg))
        end

    end

    private

      module Position #:nodoc:
        class << self

          def convert(str)
            (expr =
              case str.sub(/(\$|\^)$/,'')
              when '0' then nil
              when /^(\d+)$/, /^=(\d+)$/ then '[%s]' % $1
              when /^!=(\d+)$/ then '[position()!=%s]' % $1
              when /^(\d+)~(\d+)$/ then '[position()>=%s and position()<=%s]' % [$1,$2]
              when /^(\d+)!~(\d+)$/ then '[not(position()>=%s and position()<=%s)]' % [$1,$2]
              when /^(>)(\d+)$/, /^(>=)(\d+)$/, /^(<)(\d+)$/, /^(<=)(\d+)$/ then '[position()%s%s]' % [$1,$2]
              else nil
              end
            ) && expr.extend(Extensions).init(str.end_with?('^'))
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
