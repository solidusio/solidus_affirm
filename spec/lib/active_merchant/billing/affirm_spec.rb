require 'spec_helper'

describe ActiveMerchant::Billing::Affirm do
  let(:affirm_payment) { create(:affirm_payment) }
  let(:charge_id) { "1234-5678-9012" }

  def expect_request(method, url_regexp, data, successful_response = true, response = {})
    affirm_payment.payment_method.provider.should_receive(:ssl_request) { |m, url, d, _headers|
      # check method type
      m.should be(method)

      # test path
      url.should match(url_regexp) unless url_regexp.nil?

      # test data
      d.should eq(data.to_json) unless d.nil?

      # create response
      response = (response || {}).reverse_merge({
        id: charge_id,
        pending: true,
        amount: 8_000
      })

      response[:status_code] = 400 unless successful_response

      response.to_json
    }.at_least(1).times
  end

  def expect_request_and_return_success(method, url_regexp, data, response = nil)
    expect_request(method, url_regexp, data, true, response)
  end

  def expect_request_and_return_failure(method, url_regexp, data, response = nil)
    expect_request(method, url_regexp, data, false, response)
  end

  def expect_post_and_return_success(url_regexp = nil, data = nil, response = nil)
    expect_request_and_return_success(:post, url_regexp, data, response)
  end

  def expect_post_and_return_failure(url_regexp = nil, data = nil, response = nil)
    expect_request_and_return_failure(:post, url_regexp, data, response)
  end

  def expect_get_and_return_success(url_regexp = nil, data = nil, response = nil)
    expect_request_and_return_success(:get, url_regexp, data, response)
  end

  def expect_get_and_return_failure(url_regexp = nil, data = nil, response = nil)
    expect_request_and_return_failure(:get, url_regexp, data, response)
  end

  describe "#authorize" do
    it "sends a POST to /api/v2/charges/ with the checkout_token" do
      expect_post_and_return_success(
        /\/api\/v2\/charges/,
        { checkout_token: affirm_payment.source.token },
        { amount: 8_000 }
      )
      affirm_payment.payment_method.provider.authorize(8_000, affirm_payment.source)
    end

    context "when the POST response is not successful" do
      it "returns the result from the POST" do
        expect_post_and_return_failure nil, nil, { message: "Whoops!" }
        result = affirm_payment.payment_method.provider.authorize(8_000, affirm_payment.source)
        expect(result.success?).to be(false)
        expect(result.message).to eq("Whoops!")
      end
    end

    context "when the POST respone is successful" do
      context "when the auth amount does not match the given amount" do
        it "returns an error response for that error" do
          expect_post_and_return_success(
            /\/api\/v2\/charges/,
            { checkout_token: affirm_payment.source.token },
            { amount: 9_000 }
          )
          result = affirm_payment.payment_method.provider.authorize(1_999, affirm_payment.source)
          expect(result.success?).to be(false)
          expect(result.message).to eq("Auth amount does not match charge amount")
        end
      end

      context "when the charge is not pending in the response" do
        it "returns an error response for that error" do
          expect_post_and_return_success(
            /\/api\/v2\/charges/,
            { checkout_token: affirm_payment.source.token },
            { amount: 9_000, pending: false }
          )
          result = affirm_payment.payment_method.provider.authorize(9_000, affirm_payment.source)
          expect(result.success?).to be(false)
          expect(result.message).to eq("There was an error authorizing this Charge")
        end
      end

      it "returns the result from the POST" do
        expect_post_and_return_success(
          /\/api\/v2\/charges/,
          { checkout_token: affirm_payment.source.token },
          { amount: 9_000 }
        )
        result = affirm_payment.payment_method.provider.authorize(9_000, affirm_payment.source)
        expect(result.success?).to be(true)
        expect(result.params['amount']).to eq(9_000)
      end
    end
  end

  describe "#purchase" do
    it "authorizes the charge" do
      expect_post_and_return_failure(
        /\/api\/v2\/charges/,
        { checkout_token: affirm_payment.source.token }
      )
      affirm_payment.payment_method.provider.purchase(8_000, affirm_payment.source)
    end

    context "when the authorize response is not successful" do
      it "returns the response of the auth response" do
        expect_post_and_return_failure(
          /\/api\/v2\/charges/,
          { checkout_token: affirm_payment.source.token }
        )
        purchase_result = affirm_payment.payment_method.provider.purchase(8_000, affirm_payment.source)
        auth_result = affirm_payment.payment_method.provider.authorize(8_000, affirm_payment.source)

        [:success?, :params, :message].each do |method|
          expect(purchase_result.send(method)).to eq(auth_result.send(method))
        end
      end

      it "does not attempt to capture the charge" do
        expect_post_and_return_failure(
          /\/api\/v2\/charges/,
          { checkout_token: affirm_payment.source.token }
        )
        affirm_payment.payment_method.provider.should_not_receive(:capture)
        affirm_payment.payment_method.provider.purchase(8_000, affirm_payment.source)
      end
    end

    context "when the authorize response is successful" do
      it "captures the charge" do
        expect_post_and_return_success(
          /\/api\/v2\/charges/,
          { checkout_token: affirm_payment.source.token }
        )
        affirm_payment.payment_method.provider.should_receive(:capture)
        affirm_payment.payment_method.provider.purchase(8_000, affirm_payment.source)
      end
    end
  end

  describe "#capture" do
    it "calls a POST to charges/[charge_ari]/capture" do
      expect_post_and_return_success(
        /\/api\/v2\/charges\/#{charge_id}\/capture/,
        { amount: "8000" }
      )
      affirm_payment.payment_method.provider.capture(8_000, charge_id)
    end

    context "when the capture response is not successful" do
      it "returns the response" do
        expect_post_and_return_failure(
          /\/api\/v2\/charges\/#{charge_id}\/capture/,
          { amount: "8_000" },
          message: "buuuuuusted"
        )
        result = affirm_payment.payment_method.provider.capture(8_000, charge_id)
        expect(result.success?).to be(false)
        expect(result.message).to eq("buuuuuusted")
      end
    end

    context "when the capture response is successful" do
      it "returns the response" do
        expect_post_and_return_success(
          /\/api\/v2\/charges\/#{charge_id}\/capture/,
          { amount: "8000" },
          amount: 8_000
        )
        result = affirm_payment.payment_method.provider.capture(8_000, charge_id)
        expect(result.success?).to be(true)
        expect(result.params['amount']).to eq(8_000)
      end

      context "when the captured amount does not equal the requested amount" do
        it "returns a failed response" do
          expect_post_and_return_success(
            /\/api\/v2\/charges\/#{charge_id}\/capture/,
            { amount: "8000" },
            amount: 299
          )
          result = affirm_payment.payment_method.provider.capture(8_000, charge_id)
          expect(result.success?).to be(false)
          expect(result.message).to eq("Capture amount does not match charge amount")
        end
      end
    end
  end

  describe "#void" do
    it "calls POST on /charges/[charge_ari]/void" do
      expect_post_and_return_success(/\/api\/v2\/charges\/#{charge_id}\/void/)
      affirm_payment.payment_method.provider.void(charge_id)
    end

    it "returns the response from the POST request" do
      expect_post_and_return_success(/\/api\/v2\/charges\/#{charge_id}\/void/)
      result = affirm_payment.payment_method.provider.void(charge_id)
      expect(result.success?).to be(true)
      expect(result.message).to eq("Transaction approved")
    end
  end

  describe "#refund" do
    it "calls POST on /charges/[charge_ari]/refund" do
      expect_post_and_return_success(
        /\/api\/v2\/charges\/#{charge_id}\/refund/,
        { amount: "8000" }
      )
      affirm_payment.payment_method.provider.refund(8_000, charge_id)
    end

    it "returns the response from the POST request" do
      expect_post_and_return_success(
        /\/api\/v2\/charges\/#{charge_id}\/refund/,
        { amount: "8000" }
      )
      result = affirm_payment.payment_method.provider.refund(8_000, charge_id)
      expect(result.success?).to be(true)
      expect(result.message).to eq("Transaction approved")
    end
  end

  describe "#credit" do
    context "when the requested amount is non zero" do
      it "calls refund with the requested amount" do
        affirm_payment.payment_method.provider.should_receive(:refund).with(8_000, charge_id, {})
        affirm_payment.payment_method.provider.credit(8_000, charge_id)
      end
    end

    context "when the requested amount is zero" do
      it "returns a valid response and does not call refund()" do
        affirm_payment.payment_method.provider.should_not_receive(:refund)
        result = affirm_payment.payment_method.provider.credit(0, charge_id)
        expect(result.success?).to be(true)
      end
    end
  end

  describe "#get_checkout" do
    it "makes a GET request to /checkout/[checkout_token]" do
      expect_get_and_return_success(/\/api\/v2\/checkout\/#{affirm_payment.source.token}/)
      affirm_payment.payment_method.provider.get_checkout(affirm_payment.source.token)
    end
  end

  describe "#commit" do
    context "when a ResponseError is returned" do
      it "returns an invalid response error" do
        http_response = double
        http_response.stub(:code).and_return('400')
        http_response.stub(:body).and_return("{}")
        affirm_payment.payment_method.provider.should_receive(:ssl_request).and_raise ActiveMerchant::ResponseError.new(http_response)
        result = affirm_payment.payment_method.provider.commit(:post, "test")
        expect(result.success?).to be(false)
      end

      context "when the error response has malformed json" do
        it "returns an invalid response error" do
          http_response = double
          http_response.stub(:code).and_return('400')
          http_response.stub(:body).and_return("{///xdf2fas!!+")
          affirm_payment.payment_method.provider.should_receive(:parse).and_raise JSON::ParserError
          affirm_payment.payment_method.provider.should_receive(:ssl_request).and_raise ActiveMerchant::ResponseError.new(http_response)
          result = affirm_payment.payment_method.provider.commit(:post, "test")
          expect(result.success?).to be(false)
          expect(result.params['error']['message']).to match(/The raw response returned by the API was/)
        end
      end
    end

    context "when malformed JSON is returned" do
      it "returns an invalid response error" do
        affirm_payment.payment_method.provider.should_receive(:ssl_request).and_raise JSON::ParserError
        result = affirm_payment.payment_method.provider.commit(:post, "test")
        expect(result.success?).to be(false)
        expect(result.params['error']['message']).to match(/The raw response returned by the API was/)
      end
    end
  end
end
