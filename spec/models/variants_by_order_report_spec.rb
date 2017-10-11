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

      context 'and the order does not belong to the order_cycle' do
        let(:other_order_cycle) { create(:order_cycle, coordinator: enterprise) }
        let(:order) do
          create(:order, customer: customer, order_cycle: other_order_cycle, state: state)
        end

        it { is_expected.not_to include(order) }
      end

      context 'and the order belongs to the order_cycle' do
        it { is_expected.to include(order) }

        it 'contains the customer name' do
          expect(orders_including_customer.first.customer.name).to eq(customer.name)
        end
      end
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
