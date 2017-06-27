require 'spec_helper'

RSpec.describe SolidusAffirm::Checkout do
  subject { SolidusAffirm::Checkout.new }

  it "supports the capture, void and credit actions" do
    expect(subject.actions).to eql ["capture", "void", "credit"]
  end
end
