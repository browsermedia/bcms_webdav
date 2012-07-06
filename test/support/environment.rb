# Load the seed data once at the beginning of the test run.
silence_stream(STDOUT) do
  load "#{Rails.root}/db/seeds.rb"
end