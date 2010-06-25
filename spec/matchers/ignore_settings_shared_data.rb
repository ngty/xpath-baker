def xpf_immune_settings_args(*args)
  mx = lambda{|name| XPF::Spec::Matchers::X.const_get(name) }
  my = lambda{|name| XPF::Spec::Matchers::Y.const_get(name) }
  {
    :greedy             => [{:greedy => true}, {:greedy => false}, %w{g}, %w{!g}],
    :match_ordering     => [{:match_ordering => true}, {:match_ordering => false}, %w{o}, %w{!o}],
    :case_sensitive     => [{:case_sensitive => true}, {:case_sensitive => false}, %w{c}, %w{!c}],
    :include_inner_text => [{:include_inner_text => true}, {:include_inner_text => false}, %w{i}, %w{!i}],
    :normalize_space    => [{:normalize_space => true}, {:normalize_space => false}, %w{n}, %w{!n}],
    :comparison         => [{:comparison => '!='}, {:comparison => '='}, %w{!=}, %w{!=}],
    :scope              => [{:scope => '//awe/some/'}, {:scope => '/wonderous/'}, %w{//awe/some/}, %w{/wonderous/}],
    :position           => [{:position => 0}, {:position => 10}, %w{0}, %w{10}],
    :axial_node         => [{:axial_node => :child}, {:axial_node => :parent}, %w{parent::*}, %w{child::*}],
    :element_matcher    => [{(k = :element_matcher) => mx[:Element]}, {k => my[:Element]}, [mx[:Element]], [mx[:Element]]],
    :attribute_matcher  => [{(k = :attribute_matcher) => mx[:Attribute]}, {k => my[:Attribute]}, [mx[:Attribute]], [my[:Attribute]]],
    :text_matcher       => [{(k = :text_matcher) => mx[:Text]}, {k => my[:Text]}, [mx[:Text]], [my[:Text]]],
    :any_text_matcher   => [{(k = :any_text_matcher) => mx[:AnyText]}, {k => my[:AnyText]}, [mx[:AnyText]], [my[:AnyText]]],
    :literal_matcher    => [{(k = :literal_matcher) => mx[:Literal]}, {k => my[:Literal]}, [mx[:Literal]], [my[:Literal]]],
    :group_matcher      => [{(k = :group_matcher) => mx[:Group]}, {k => my[:Group]}, [mx[:Group]], [my[:Group]]]
  }.select{|setting,_| args.include?(setting) }
end
