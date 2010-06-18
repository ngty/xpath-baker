def xpf_invalid_permutated_arguments
[
  ['attr1'],
  [:attr1],

  ['attr1', 'attr2'],
  [:attr1, :attr2],

  ['attr1', [{:attr2 => 2}, {:position => 2}]],
  [:attr1, [{:attr2 => 2}, {:position => 2}]],
  ['attr1', [{:attr2 => 2}]],
  [:attr1, [{:attr2 => 2}]],
  ['attr1', {:attr2 => 2}],
  [:attr1, {:attr2 => 2}],
  ['attr1', [[:attr2], {:position => 2}]],
  [:attr1, [[:attr2], {:position => 2}]],
  ['attr1', [[:attr2]]],
  [:attr1, [[:attr2]]],
  ['attr1', [:attr2]],
  [:attr1, [:attr2]],

  [[{:attr2 => 2}, {:position => 2}], 'attr1'],
  [[{:attr2 => 2}, {:position => 2}], :attr1],
  [[{:attr2 => 2}], 'attr1'],
  [[{:attr2 => 2}], :attr1],
  [{:attr2 => 2}, 'attr1'],
  [{:attr2 => 2}, :attr1],
  [[[:attr2], {:position => 2}], 'attr1'],
  [[[:attr2], {:position => 2}], :attr],
  [[[:attr2]], 'attr1'],
  [[[:attr2]], :attr1],
  [[:attr2], 'attr1'],
  [[:attr2], :attr1],
]
end

def xpf_valid_permutated_arguments
{
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}]]                                              => [[m1], [c1]],
  [[m1 = [:attr1], c1 = {:position => 1}]]                                                   => [[m1], [c1]],
  [[m1 = {:attr1 => 1}]]                                                                     => [[m1], [{}]],
  [[m1 = [:attr1]]]                                                                          => [[m1], [{}]],
  [m1 = [:attr1]]                                                                            => [[m1], [{}]],
  [m1 = {:attr1 => 1}]                                                                       => [[m1], [{}]],

  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}]] => [[m1,m2], [c1,c2]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}]]      => [[m1,m2], [c1,c2]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = [:attr2], c2 = {:position => 2}]]      => [[m1,m2], [c1,c2]],

  [[m1 = {:attr1 => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}]]                        => [[m1,m2], [{},c2]],
  [[m1 = [:attr1]], [m2 = {:attr2 => 2}, c2 = {:position => 2}]]                             => [[m1,m2], [{},c2]],
  [[m1 = {:attr1 => 1}], [m2 = [:attr2], c2 = {:position => 2}]]                             => [[m1,m2], [{},c2]],

  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}]]                        => [[m1,m2], [c1,{}]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = {:attr2 => 2}]]                             => [[m1,m2], [c1,{}]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = [:attr2]]]                             => [[m1,m2], [c1,{}]],

  [m1 = [:attr1], [m2 = {:attr2 => 2}, c2 = {:position => 2}]]                               => [[m1,m2], [{},c2]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], m2 = [:attr2]]                               => [[m1,m2], [c1,{}]],
  [m1 = [:attr1], [m2 = {:attr2 => 2}]]                                                      => [[m1,m2], [{},{}]],
  [[m1 = {:attr1 => 1}], m2 = [:attr2]]                                                      => [[m1,m2], [{},{}]],
  [m1 = [:attr1], m2 = {:attr2 => 2}]                                                        => [[m1,m2], [{},{}]],
  [m1 = {:attr1 => 1}, m2 = [:attr2]]                                                        => [[m1,m2], [{},{}]],

  # Well, the followings are actually not needed, but anyway, since they are done,
  # and specs run fast, we just leave them around (to be safe, i guess).
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]  => [[m1,m2,m3], [c1,c2,c3]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = [:attr2], c2 = {:position => 2}], [m3 = [:attr3], c3 = {:position => 3}]]                 => [[m1,m2,m3], [c1,c2,c3]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]       => [[m1,m2,m3], [c1,c2,c3]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = [:attr2], c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]       => [[m1,m2,m3], [c1,c2,c3]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = [:attr3], c3 = {:position => 3}]]       => [[m1,m2,m3], [c1,c2,c3]],

  [[m1 = {:attr1 => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                         => [[m1,m2,m3], [{},c2,c3]],
  [[m1 = [:attr1]], [m2 = [:attr2], c2 = {:position => 2}], [m3 = [:attr3], c3 = {:position => 3}]]                                        => [[m1,m2,m3], [{},c2,c3]],
  [[m1 = [:attr1]], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                              => [[m1,m2,m3], [{},c2,c3]],
  [[m1 = {:attr1 => 1}], [m2 = [:attr2], c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                              => [[m1,m2,m3], [{},c2,c3]],
  [[m1 = {:attr1 => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = [:attr3], c3 = {:position => 3}]]                              => [[m1,m2,m3], [{},c2,c3]],

  [m1 = {:attr1 => 1}, [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                           => [[m1,m2,m3], [{},c2,c3]],
  [m1 = [:attr1], [m2 = [:attr2], c2 = {:position => 2}], [m3 = [:attr3], c3 = {:position => 3}]]                                          => [[m1,m2,m3], [{},c2,c3]],
  [m1 = [:attr1], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                                => [[m1,m2,m3], [{},c2,c3]],
  [m1 = {:attr1 => 1}, [m2 = [:attr2], c2 = {:position => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                                => [[m1,m2,m3], [{},c2,c3]],
  [m1 = {:attr1 => 1}, [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = [:attr3], c3 = {:position => 3}]]                                => [[m1,m2,m3], [{},c2,c3]],

  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                         => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = [:attr2]], [m3 = [:attr3], c3 = {:position => 3}]]                                        => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = {:attr2 => 2}], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                              => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = [:attr2]], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                              => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}], [m3 = [:attr3], c3 = {:position => 3}]]                              => [[m1,m2,m3], [c1,{},c3]],

  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], m2 = {:attr2 => 2}, [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                           => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = [:attr1], c1 = {:position => 1}], m2 = [:attr2], [m3 = [:attr3], c3 = {:position => 3}]]                                          => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = [:attr1], c1 = {:position => 1}], m2 = {:attr2 => 2}, [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                                => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], m2 = [:attr2], [m3 = {:attr3 => 3}, c3 = {:position => 3}]]                                => [[m1,m2,m3], [c1,{},c3]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], m2 = {:attr2 => 2}, [m3 = [:attr3], c3 = {:position => 3}]]                                => [[m1,m2,m3], [c1,{},c3]],

  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}]]                         => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = [:attr2], c2 = {:position => 2}], [m3 = [:attr3]]]                                        => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = {:attr3 => 3}]]                              => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = [:attr2], c2 = {:position => 2}], [m3 = {:attr3 => 3}]]                              => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], [m3 = [:attr3]]]                              => [[m1,m2,m3], [c1,c2,{}]],

  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], m3 = {:attr3 => 3}]                           => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = [:attr2], c2 = {:position => 2}], m3 = [:attr3]]                                          => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = [:attr1], c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], m3 = {:attr3 => 3}]                                => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = [:attr2], c2 = {:position => 2}], m3 = {:attr3 => 3}]                                => [[m1,m2,m3], [c1,c2,{}]],
  [[m1 = {:attr1 => 1}, c1 = {:position => 1}], [m2 = {:attr2 => 2}, c2 = {:position => 2}], m3 = [:attr3]]                                => [[m1,m2,m3], [c1,c2,{}]],
}
end
