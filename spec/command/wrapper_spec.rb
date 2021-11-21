require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Wrapper do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ wrapper }).should.be.instance_of Command::Wrapper
      end
    end
  end
end

