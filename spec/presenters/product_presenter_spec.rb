require 'rails_helper'

describe ProductPresenter do
  subject { described_class.new(product).units }

  describe '#units' do
    let(:product) do
      create(
        :product,
        variant_unit: variant_unit,
        variant_unit_name: variant_unit_name,
        variant_unit_scale: variant_unit_scale
      )
    end

    context 'when the product has an items unit' do
      let(:variant_unit) { 'items' }
      let(:variant_unit_name) { 'dozen' }
      let(:variant_unit_scale) { nil }

      it { is_expected.to eq(product.variant_unit_name) }
    end

    context 'when the product has weight unit' do
      let(:variant_unit) { 'weight' }
      let(:variant_unit_name) { nil }
      let(:variant_unit_scale) { 1 }

      it { is_expected.to eq('g') }
    end

    context 'when the product has a volume unit' do
      let(:variant_unit) { 'volume' }
      let(:variant_unit_name) { nil }
      let(:variant_unit_scale) { 1 }

      it { is_expected.to eq('L') }
    end
  end
end

