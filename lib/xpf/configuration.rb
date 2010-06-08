module XPF

  class ConfigSettingNotSupportedError < Exception ; end
  class InvalidConfigSettingValueError < Exception ; end

  ###
  # Generated xpaths are affected by the following configurable settings:
  #
  # 1 *text_match* affects how text node matching is done:
  #
  #   <DIV>
  #     John <SPAN>Stone <B>Jr</B></SPAN>
  #   </DIV>
  #
  # Using DIV as the reference node:
  # <table>
  # <tr>
  # <th>Modes Supported</th>
  # <th>Nodes Considered</th>
  # <th>Texts Matched</th>
  # <th>XPath Fragment</th>
  # </tr>
  # <tr>
  # <td>:any_text</td>
  # <td>DIV, SPAN & B</td>
  # <td>'John ', 'Stone ' & 'Jr'</td>
  # <td>?DIV[./descendant-or-self::*[text()=?]]</td>
  # </tr>
  # <tr>
  # <td>:descendant_text</td>
  # <td>SPAN & B</td>
  # <td>'Stone ' & 'Jr'</td>
  # <td>?DIV[./descendant::*[text()=?]]</td>
  # </tr>
  # <tr>
  # <td>:self_text</td>
  # <td>DIV</td>
  # <td>'John '</td>
  # <td>?DIV[text()=?]</td>
  # </tr>
  # <tr>
  # <td>:any_inner_text</td>
  # <td>DIV, SPAN & B</td>
  # <td>'John Stone Jr', 'Stone Jr', 'Jr'</td>
  # <td>?DIV[./descendant-or-self::*[.=?]]</td>
  # </tr>
  # <tr>
  # <td>:descendant_inner_text</td>
  # <td>SPAN & B</td>
  # <td>'Stone Jr' & 'Jr'</td>
  # <td>?DIV[./descendant::*[.=?]]</td>
  # </tr>
  # <tr>
  # <td>:self_inner_text</td>
  # <td>DIV</td>
  # <td>'John Stone Jr'</td>
  # <td>?DIV[.=?]</td>
  # </tr>
  # </table>
  #
  # 2 *case_sensitive* determines if match should be case sensitive:
  #
  #   <INPUT VALUE="sunny"/>
  #
  # <table>
  # <tr>
  # <th>Flags Supported</th>
  # <th>Texts Matched</th>
  # <th>XPath Fragment</th>
  # </tr>
  # <tr>
  # <td>true</td>
  # <td>'sunny'</td>
  # <td>?INPUT[@VALUE="sunny"]</td>
  # </tr>
  # <tr>
  # <td>false</td>
  # <td>'sunny', 'SUNNY', 'SuNny', etc</td>
  # <td>?INPUT[translate(@VALUE,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")="sunny"]</td>
  # </tr>
  # <tr>
  #
  # 3 *match_ordering*
  #
  # 4 *normalize_space*
  #
  # 5 *position*
  #
  #
  class Configuration

    DEFAULT_SETTINGS = {
      :case_sensitive     => true,
      :match_ordering     => true,
      :normalize_space    => true,
      :include_inner_text => true,
      :position           => nil,
      :axis               => :self
    }

    SETTING_VALIDATORS = {
      :case_sensitive     => :is_boolean!,
      :match_ordering     => :is_boolean!,
      :normalize_space    => :is_boolean!,
      :include_inner_text => :is_boolean!,
      :position           => :is_valid_position!,
      :axis               => :is_valid_axis!
    }

    class << self

      DEFAULT_SETTINGS.keys.each do |setting|

        attr_accessor setting
        alias_method :"#{setting}?", setting

        define_method(:"#{setting}=") do |val|
          send(SETTING_VALIDATORS[setting], setting, val) &&
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
