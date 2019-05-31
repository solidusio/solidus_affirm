require 'spec_helper'

RSpec.describe SolidusAffirm::Checkout do
  subject { described_class.new }

  it 'supports the capture, void and credit actions' do
    expect(subject.actions).to eq %w[capture void credit]
  end

  describe '#can_capture?' do
    let(:payment) { instance_double('Spree::Payment') }

    context 'when the payment is still in checkout' do
      before do
        allow(payment).to receive(:checkout?).and_return(true)
        allow(payment).to receive(:pending?).and_return(false)
      end

      it 'returns true' do
        expect(subject.can_capture?(payment)).to eq(true)
      end
    end

    context 'when the payment is pending' do
      before do
        allow(payment).to receive(:checkout?).and_return(false)
        allow(payment).to receive(:pending?).and_return(true)
      end

      it 'returns true' do
        expect(subject.can_capture?(payment)).to eq(true)
      end
    end

    context 'when the payment is neither in checkout nor pending' do
      before do
        allow(payment).to receive(:checkout?).and_return(false)
        allow(payment).to receive(:pending?).and_return(false)
      end

      it 'returns false' do
        expect(subject.can_capture?(payment)).to eq(false)
      end
    end
  end

  describe '#can_void?' do
    let(:payment) { instance_double('Spree::Payment') }

    context 'when the payment is neither failed nor void' do
      before do
        allow(payment).to receive(:failed?).and_return(false)
        allow(payment).to receive(:void?).and_return(false)
      end

      it 'returns true' do
        expect(subject.can_void?(payment)).to eq(true)
      end
    end

    context 'when the payment is failed' do
      before do
        allow(payment).to receive(:failed?).and_return(true)
        allow(payment).to receive(:void?).and_return(false)
      end

      it 'returns false' do
        expect(subject.can_void?(payment)).to eq(false)
      end
    end

    context 'when the payment is void' do
      before do
        allow(payment).to receive(:failed?).and_return(false)
        allow(payment).to receive(:void?).and_return(true)
      end

      it 'returns false' do
        expect(subject.can_void?(payment)).to eq(false)
      end
    end
  end

  describe '#can_credit?' do
    let(:payment) { instance_double('Spree::Payment') }

    context 'when the payment is completed and creditable' do
      before do
        allow(payment).to receive(:completed?).and_return(true)
        allow(payment).to receive(:credit_allowed).and_return(1)
      end

      it 'returns true' do
        expect(subject.can_credit?(payment)).to eq(true)
      end
    end

    context 'when the payment is not completed' do
      before do
        allow(payment).to receive(:completed?).and_return(false)
        allow(payment).to receive(:credit_allowed).and_return(1)
      end

      it 'returns false' do
        expect(subject.can_credit?(payment)).to eq(false)
      end
    end

    context 'when the payment is not creditable' do
      before do
        allow(payment).to receive(:completed?).and_return(true)
        allow(payment).to receive(:credit_allowed).and_return(0)
      end

      it 'returns false' do
        expect(subject.can_credit?(payment)).to eq(false)
      end
    end
  end

  describe "#reusable?" do
    it "is never reusable" do
      expect(subject.reusable?).to eq(false)
    end
  end
end
