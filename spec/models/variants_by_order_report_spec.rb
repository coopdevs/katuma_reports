require 'rails_helper'

describe VariantsByOrderReport do
  let(:variants_by_order_report) { described_class.new(order_cycle) }

  let(:customer) { create(:customer, name: 'Customer Name') }
  let(:enterprise) { create(:enterprise) }
  let(:order_cycle) { create(:order_cycle, coordinator: enterprise) }

  describe '#orders_including_customer' do
    subject(:orders_including_customer) do
      variants_by_order_report.orders_including_customer
    end

    let(:variant) { create(:variant) }
    let(:order) do
      create(:order, customer: customer, order_cycle: order_cycle, state: state)
    end

    before do
      create(:line_item, order: order, variant: variant, quantity: 4)
    end

    context 'when the order is not completed' do
      let(:state) { 'cart' }

      it { is_expected.not_to include(order) }
    end

    context 'when the order is completed' do
      let(:state) { 'complete' }

      context 'and the order does not belong to the order cycle' do
        let(:other_order_cycle) { create(:order_cycle, coordinator: enterprise) }
        let(:order) do
          create(:order, customer: customer, order_cycle: other_order_cycle, state: state)
        end

        it { is_expected.not_to include(order) }
      end

      context 'and the order belongs to the order cycle' do
        it { is_expected.to include(order) }

        it 'contains the customer name' do
          expect(orders_including_customer.first.customer.name).to eq(customer.name)
        end
      end
    end
  end

  describe '#products_by_variant_id' do
    subject { variants_by_order_report.products_by_variant_id }

    let(:variant) { create(:variant) }

    before { create(:line_item, order: order, variant: variant) }

    context 'when a variant is present in a complete order of the order cycle' do
      let(:order) { create(:order, order_cycle: order_cycle, state: 'complete') }

      it { is_expected.to have_key(variant.id) }

      describe 'a hash value' do
        subject { variants_by_order_report.products_by_variant_id[variant.id]  }

        it { is_expected.to respond_to(:units) }
      end
    end

    context 'when a variant is present in multiple complete orders of the order cycle' do
      let(:order) { create(:order, order_cycle: order_cycle, state: 'complete') }
      let(:other_order) { create(:order, order_cycle: order_cycle, state: 'complete') }

      let(:product_presenter) { instance_double(ProductPresenter) }

      before do
        create(:line_item, order: order, variant: variant)
        create(:line_item, order: other_order, variant: variant)
      end

      context 'hash' do
        before do
          allow(ProductPresenter)
            .to receive(:new)
            .with(kind_of(Spree::Product))
            .and_return(product_presenter)
        end

        it { is_expected.to eq(variant.id => product_presenter) }
      end

      describe 'a hash value' do
        subject { variants_by_order_report.products_by_variant_id[variant.id]  }

        it { is_expected.to respond_to(:units) }
      end
    end

    context 'when a variant is present in an incomplete order of the order cycle' do
      let(:order) { create(:order, order_cycle: order_cycle, state: 'cart') }

      it { is_expected.not_to have_key(variant.id) }
    end

    context 'when a variant is not present in any order of the order cycle' do
      let(:other_order_cycle) { create(:order_cycle, coordinator: enterprise) }
      let(:order) do
        create(:order, order_cycle: other_order_cycle, state: 'complete')
      end

      it { is_expected.not_to have_key(variant.id) }
    end
  end

  describe '#line_item_for' do
    subject(:line_item_for_variant) { variants_by_order_report.line_item_for(variant.id, order.id) }

    let(:state) { 'complete' }

    context 'when there is a line item for the given variant an order in the order cycle' do
      let(:variant) { create(:variant) }
      let(:order) do
        create(:order, customer: customer, order_cycle: order_cycle, state: state)
      end

      let!(:line_item) do
        create(:line_item, order: order, variant: variant, quantity: 2)
      end

      context 'and the order is completed' do
        let(:state) { 'complete' }

        it 'returns an object with the line item\'s order, variant and quantity' do
          expect(line_item_for_variant.attributes).to eq(
            'order_id' => order.id,
            'variant_id' => variant.id,
            'quantity' => 2
          )
        end
      end

      context 'and the order is not completed' do
        let(:state) { 'cart' }

        it 'returns an object whose quantity is 0' do
          expect(line_item_for_variant.quantity).to eq(0)
        end
      end
    end

    context 'when there is no line item for the given variant and order in the order cycle' do
      let(:variant) { create(:variant) }
      let(:order) do
        create(:order, customer: customer, order_cycle: order_cycle, state: state)
      end

      it 'returns an object whose quantity is 0' do
        expect(line_item_for_variant.quantity).to eq(0)
      end
    end
  end
end
