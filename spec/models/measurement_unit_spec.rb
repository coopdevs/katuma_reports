require 'rails_helper'

describe MeasurementUnit do
  subject { described_class.new(type, scale).to_s }

  context 'when the product has a weight type' do
    let(:type) { 'weight' }

    context 'and 1 as scale' do
      let(:scale) { 1 }
      it { is_expected.to eq('g') }
    end

    context 'and 1000 as scale' do
      let(:scale) { 1000 }
      it { is_expected.to eq('kg') }
    end

    context 'and 1_000_000 as scale' do
      let(:scale) { 1_000_000 }
      it { is_expected.to eq('T') }
    end

    context 'and there is no such scale' do
      let(:scale) { 10 }

      it 'raises' do
        expect { described_class.new(type, scale).to_s }
          .to raise_error(described_class::Error)
      end
    end
  end

  context 'when the product has a volume type' do
    let(:type) { 'volume' }

    context 'and 0.001 as scale' do
      let(:scale) { 0.001 }
      it { is_expected.to eq('mL') }
    end

    context 'and 1 as scale' do
      let(:scale) { 1 }
      it { is_expected.to eq('L') }
    end

    context 'and 1000 as scale' do
      let(:scale) { 1000 }
      it { is_expected.to eq('kL') }
    end

    context 'and there is no such scale' do
      let(:scale) { 10 }

      it 'raises' do
        expect { described_class.new(type, scale).to_s }
          .to raise_error(described_class::Error)
      end
    end
  end

  context 'when the product has a items type' do
    subject { described_class.new(type, scale, name).to_s }

    let(:type) { 'items' }
    let(:scale) { nil }
    let(:name) { 'pack' }

    it { is_expected.to eq(name) }
  end

  context 'without a type' do
    let(:type) { nil }

    context 'but a scale' do
      let(:scale) { 1 }

      it 'raises' do
        expect { described_class.new(type, scale).to_s }
          .to raise_error(described_class::Error)
      end
    end

    context 'but a 0 scale' do
      let(:scale) { 0 }

      it 'raises' do
        expect { described_class.new(type, scale).to_s }
          .to raise_error(described_class::Error)
      end
    end

    context 'and a scale' do
      let(:scale) { nil }

      it 'raises' do
        expect { described_class.new(type, scale).to_s }
          .to raise_error(described_class::Error)
      end
    end
  end
end
