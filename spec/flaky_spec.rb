RSpec.describe 'FlakySpec' do
  it 'should flake on 2 options', :flaky do
    expect([true, false].sample).to eq(true)
  end

  it 'should flake on 3 options' do
    expect([true, false, false].sample).to eq(true)
  end

  it 'should flake on 4 options' do
    expect([true, false, false, true].sample).to eq(true)
  end
end
