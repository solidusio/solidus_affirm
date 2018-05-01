require 'spec_helper'

RSpec.describe SolidusAffirm::LineItemSerializer do
  let(:line_item) { create(:line_item, price: BigDecimal('14.99')) }
  let(:serializer) { SolidusAffirm::LineItemSerializer.new(line_item, root: false) }
  subject { JSON.parse(serializer.to_json) }

  describe 'display_name' do
    it "return the line_item variant name" do
      expect(subject["display_name"]).to eql line_item.name
    end
  end

  describe "unit_price" do
    it "returns the line_item price in cents" do
      expect(subject["unit_price"]).to eql 1_499
    end
  end

  describe "qty" do
    it "return the line_item quantity" do
      expect(subject["qty"]).to eql 1
    end
  end

  describe "item_image_url" do
    context "with variant specific image" do
      before do
        expect(line_item.variant).to receive(:images).and_return([create(:image)]).twice
      end

      it "will return the variant image url" do
        expect(subject['item_image_url']).to match /\/spree\/products\/\d\/large\/thinking-cat.jpg/
      end
    end

    context "when the variant does not have an image" do
      before do
        expect(line_item.variant).to receive(:images).and_return([])
        expect(line_item.variant.product).to receive(:images).and_return([create(:image)]).twice
      end

      it "will return the master product image url" do
        expect(subject['item_image_url']).to match /\/spree\/products\/\d\/large\/thinking-cat.jpg/
      end
    end
  end

  describe "item_url" do
    let(:product) { line_item.product }
    let(:product_url) do
      Spree::Core::Engine.routes.url_helpers.product_url(product)
    end

    it "is the url from the line_item product" do
      expect(subject['item_url']).to eql product_url
    end
  end
end
