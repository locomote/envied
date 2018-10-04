RSpec.describe ENVied::Configuration do
  it { is_expected.to respond_to :variable }
  it { is_expected.to respond_to :group }
  it { is_expected.to respond_to :enable_defaults! }
  it { is_expected.to respond_to :type }

  describe '#variable' do
    subject { config.variables }

    context "with type" do
      let(:config) do
        described_class.new do
          variable :foo, :boolean
        end
      end

      it { is_expected.to include(ENVied::Variable.new(:foo, :boolean)) }
    end

    describe "with default" do
      let(:config) do
        described_class.new do
          variable :bar, default: 'bar'
        end
      end

      it { is_expected.to include(ENVied::Variable.new(:bar, :string, default: 'bar')) }
    end

    describe 'without type' do
      let(:config) do
        described_class.new do
          variable :bar
        end
      end

      it { is_expected.to include(ENVied::Variable.new(:bar, :string)) }
    end
  end

  def with_envfile(**options, &block)
    @config = ENVied::Configuration.new(options, &block)
  end
  attr_reader :config

  describe 'variables' do
    it 'results in an added variable' do
      with_envfile do
        variable :foo, :boolean
      end

      expect(config.variables).to include ENVied::Variable.new(:foo, :boolean, group: :default)
    end

    it 'sets a default value when specified' do
      with_envfile do
        variable :bar, default: 'bar'
      end

      expect(config.variables).to include ENVied::Variable.new(:bar, :string, default: 'bar', group: :default)
    end

    it 'sets a default value when specified' do
      with_envfile do
        variable :bar, default: 'bar'
      end

      expect(config.variables).to include ENVied::Variable.new(:bar, :string, default: 'bar', group: :default)
    end

    it 'sets specific group for variable' do
      with_envfile do
        group :production do
          variable :SECRET_KEY_BASE
        end
      end

      expect(config.variables).to include ENVied::Variable.new(:SECRET_KEY_BASE, :string, group: :production)
    end

    it 'sets the same variable for multiple groups' do
      with_envfile do
        group :development, :test do
          variable :DISABLE_PRY, :boolean, default: 'false'
        end
      end

      expect(config.variables).to eq [
        ENVied::Variable.new(:DISABLE_PRY, :boolean, default: 'false', group: :development),
        ENVied::Variable.new(:DISABLE_PRY, :boolean, default: 'false', group: :test)
      ]
    end
  end

  describe '#type' do
    subject { config.coercer.custom_types }

    let(:coercer) { ->(raw_string) { Integer(raw_string) ** 2 } }
    let(:config) do
      block = coercer
      described_class.new do
        type(:power_integer, &block)
      end
    end

    it 'creates type with given coercing block' do
      is_expected.to include(power_integer: ENVied::Type.new(:power_integer, coercer))
    end
  end
end
