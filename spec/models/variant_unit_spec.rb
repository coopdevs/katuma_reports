require 'rails_helper'

describe VariantUnit do
  subject { VariantUnit.new(variant_unit, variant_unit_scale).to_s }

  context 'when the product has a weight variant_unit' do
    let(:variant_unit) { 'weight' }

    context 'and 1 as variant_unit_scale' do
      let(:variant_unit_scale) { 1 }
      it { is_expected.to eq('g') }
    end

    context 'and 1000 as variant_unit_scale' do
      let(:variant_unit_scale) { 1000 }
      it { is_expected.to eq('kg') }
    end

    context 'and 1_000_000 as variant_unit_scale' do
      let(:variant_unit_scale) { 1_000_000 }
      it { is_expected.to eq('T') }
    end
  end

  context 'when the product has a volume variant_unit' do
    let(:variant_unit) { 'volume' }

    context 'and 0.001 as variant_unit_scale' do
      let(:variant_unit_scale) { 0.001 }
      it { is_expected.to eq('mL') }
    end

    context 'and 1 as variant_unit_scale' do
      let(:variant_unit_scale) { 1 }
      it { is_expected.to eq('L') }
    end

    context 'and 1000 as variant_unit_scale' do
      let(:variant_unit_scale) { 1000 }
      it { is_expected.to eq('kL') }
    end
  end
end
