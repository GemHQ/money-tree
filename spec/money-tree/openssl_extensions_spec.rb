require "spec_helper"

FIXED_KEY1 = <<-fixed_key
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIOvYaAN53KFhyLIElYFZCpm/Q2wq72Uu0kRcKeCDdlJVoAcGBSuBBAAK
oUQDQgAE4cdbt+NxMCBLg0cQYqo/UEwfzAONpz/n7ux+QrdKuH9NRulf9D4996x5
r7QBY+l5GJ+RgzLoXbFjPyPQtCV+/Q==
-----END EC PRIVATE KEY-----
fixed_key

FIXED_KEY2 = <<-fixed_key
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIP6nKLMEcH9R3hv695rCUl9OV+ueC9UX18F2PIH5wcFpoAcGBSuBBAAK
oUQDQgAErilvn3ms9cKHLNHHegiUU+NuW8c2f223vYInEV+s9ZNSGd28usAXZ6lN
O2zE534+k09fFe2skHtdoXbLJuZV8g==
-----END EC PRIVATE KEY-----
fixed_key

FIXED_SUM = "04F3C291542F410F61D61861D911F71ABD320A7B77ED571F92FEC533F61549BF218BAA47BD134847D89917F7483AFE20CCD9B1A4CBDFC443B389D1313B48E018F4"

describe MoneyTree::OpenSSLExtensions do
  include MoneyTree::OpenSSLExtensions

  context "with inputs" do
    let(:key1) { OpenSSL::PKey::EC.generate("secp256k1") }
    let(:key2) { OpenSSL::PKey::EC.generate("secp256k1") }
    let(:point_1) { key1.public_key }
    let(:point_2) { key2.public_key }

    let(:point_infinity) { key1.public_key.set_to_infinity! }

    let(:fixed_key1) { OpenSSL::PKey::EC.new(FIXED_KEY1) }
    let(:fixed_key2) { OpenSSL::PKey::EC.new(FIXED_KEY2) }
    let(:fixed_point1) { fixed_key1.public_key }
    let(:fixed_point2) { fixed_key2.public_key }
    let(:fixed_sum_point) { OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC::Group.new("secp256k1"), OpenSSL::BN.new(FIXED_SUM, 16)) }

    it "requires valid points" do
      expect { MoneyTree::OpenSSLExtensions.add(0, 0) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(nil, nil) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(point_1, 0) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(0, point_2) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(point_infinity, point_2) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(point_1, point_2) }.to_not raise_error
      expect { MoneyTree::OpenSSLExtensions.validate_points(point_1) }.to_not raise_error
    end

    it "validates points correctly" do
      expect { MoneyTree::OpenSSLExtensions.validate_points(point_1) }.to_not raise_error
      expect { MoneyTree::OpenSSLExtensions.validate_points(point_2) }.to_not raise_error
      expect { MoneyTree::OpenSSLExtensions.validate_points(point_infinity) }.to raise_error(ArgumentError)
    end

    it "should add points correctly" do
      result = MoneyTree::OpenSSLExtensions.add(fixed_point1, fixed_point2)

      expect(result).to eql(FIXED_SUM)

      group = OpenSSL::PKey::EC::Group.new("secp256k1")
      result_point = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(result, 16))

      expect(result_point).to eql(fixed_sum_point)
    end

    it "should be able to create the same hex output for the point" do
      hex_output = fixed_sum_point.to_bn.to_s(16)

      expect(hex_output).to eq(FIXED_SUM)
    end
  end
end
