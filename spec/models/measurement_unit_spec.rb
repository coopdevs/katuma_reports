require 'rails_helper'

describe MeasurementUnit do
  subject { MeasurementUnit.new(type, scale).to_s }

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
  end
end
