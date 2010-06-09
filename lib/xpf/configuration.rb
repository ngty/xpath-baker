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

    DEFAULT_SETTINGS = {
      :case_sensitive     => true,
      :match_ordering     => true,
      :normalize_space    => true,
      :include_inner_text => true,
      :scope              => '//',
      :position           => nil,
      :axis               => :self,
    }

    SETTING_VALIDATORS = {
      :case_sensitive     => :is_boolean!,
      :match_ordering     => :is_boolean!,
      :normalize_space    => :is_boolean!,
      :include_inner_text => :is_boolean!,
      :scope              => nil,
      :position           => :is_valid_position!,
      :axis               => :is_valid_axis!
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
      def reset
        DEFAULT_SETTINGS.each {|setting, val| send(:"#{setting}=", val) }
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
          axes = %w{
            ancestor ancestor_or_self child descendant descendant_or_self following
            following_sibling namespace parent preceding preceding_sibling self
          }.map(&:to_sym)
          msg = "Config setting :#{setting} must be any of :%s & :%s !!" %
            [axes[0..-2].map(&:to_s).join(', :'), axes[-1]]
          fail_unless(msg) { axes.include?(val) }
        end

        def fail_unless(msg, error = InvalidConfigSettingValueError)
          yield or raise(error.new(msg))
        end

    end

  end

  Configuration.reset

end
