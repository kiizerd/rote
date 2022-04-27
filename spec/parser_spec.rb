require 'parser'

RSpec.describe Parser do
  describe '#parse' do
    it 'returns a parsed option hash' do
      args = %W[ --new=FooBartoBaz ]
      parser = Parser.new
      options = parser.parse(args)
      expect(options).to eq({
        action: :new,
        content: 'FooBartoBaz'        
      })
    end
  end
end
