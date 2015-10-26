RSpec::Matchers.define :be_readable_file do
  match do |actual|
    File.readable?(actual)
  end
end