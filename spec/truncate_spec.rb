require './lib/truncate'

RSpec.describe String do
  describe '#truncate' do
    it 'returns a truncated copy of self' do
      string = 'Welcome to the party. Please make yourself comfortable.'
      expect(string.truncate.size).to be(26)
    end

    it 'truncates to given size' do
      string = 'Welcome Again!! So nice to see you so many times in one day.'
      expect(string.truncate(16).size).to be(16)
    end

    it 'concatenates ellipses by default' do
      string = 'Hello there!!'
      expect(string.truncate).to eq('Hello there!!...')
    end

    it 'disables ellipses if given false as 2nd arg' do
      string = 'Hello again'
      expect(string.truncate(string.size, false)).to eq(string)
    end
  end
end
