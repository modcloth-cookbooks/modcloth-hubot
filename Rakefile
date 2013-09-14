# encoding: utf-8

task default: :sane

desc 'Assert the sanity!'
task sane: [:rubocop, :foodcritic]

desc 'Run rubocop!'
task :rubocop do
  sh('rubocop -f simple') { |r, _| r || abort }
end

desc 'Run foodcritic!'
task :foodcritic do
  sh('foodcritic --epic-fail any .') { |r, _| r || abort }
end
