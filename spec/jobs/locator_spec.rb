require 'rspec'
require 'json'
require 'bosh/template/test'

describe 'locator job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('locator') }

  describe 'gemfire.properties' do
    let(:template) { job.template('config/gemfire.properties') }
    let(:map) { {} }

    before(:each) do
      spec = Bosh::Template::Test::InstanceSpec.new(address: '10.244.0.2', index: 0)

      links = [
        Bosh::Template::Test::Link.new(
          name: 'locator_info',
          instances: [
            Bosh::Template::Test::LinkInstance.new(address: '10.244.0.2'),
            Bosh::Template::Test::LinkInstance.new(address: '10.244.0.3'),
          ]
        )
      ]

      file = template.render({}, spec: spec, consumes: links)
      file.each_line do |line|
        (key,value) = line.split('=')
        map[key] = value.strip()
      end

    end

    it 'configures log file path fully' do
      expect(map['log-file']).to eq('/var/vcap/sys/log/locator/locator0.log')
    end

    it 'configures jmx manager hostname for clients' do
      expect(map['jmx-manager-hostname-for-clients']).to eq('10.244.0.2')
    end

    it 'configures locators property to include all locators, comma-separated, with portnum' do
      expect(map['locators']).to eq('10.244.0.2[10334],10.244.0.3[10334]')
    end

  end
end