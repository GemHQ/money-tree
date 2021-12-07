require 'spec_helper'

describe MoneyTree::PrivateKey do
  before do
    @key = MoneyTree::PrivateKey.new key: "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
  end

  describe "to_hex" do
    it "has 64 characters" do
      # must always be 64 characters - leading zeroes need to be preserved!
      expect(@key.to_hex.length).to eql(64)
    end

    it "preserves leading zeros" do
      master = MoneyTree::Master.new seed_hex: "9cf6b6e8451c7d551cb402e2997566e5c7c258543eadb184f9f39322b2e6959b"
      expect(master.node_for_path("m/427").private_key.to_hex.length).to eql(64)
    end

    it "is a valid hex" do
      expect(@key.to_hex).to eql('5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b')
    end
  end

  describe "to_wif" do
    it "is a 52 character base58 key" do
      expect(@key.to_wif.length).to eql(52)
    end

    it "starts with K or L" do
      expect(%w(K L)).to include(@key.to_wif[0])
    end

    it "is a valid compressed wif" do
      expect(@key.to_wif).to eql('KzPkwAXJ4wtXHnbamTaJqoMrzwCUUJaqhUxnqYhnZvZH6KhgmDPK')
    end
  end

  describe "to_wif(compressed: false)" do
    it "is a 51 character base58 key" do
      expect(@key.to_wif(compressed: false).length).to eql(51)
    end

    it "starts with 5" do
      expect(@key.to_wif(compressed: false)[0]).to eql('5')
    end

    it "is valid" do
      expect(@key.to_wif(compressed: false)).to eql('5JXz5ZyFk31oHVTQxqce7yitCmTAPxBqeGQ4b7H3Aj3L45wUhoa')
    end
  end

  describe "from_wif(wif)" do
    it "returns the key from a wif" do
      expect(@key.from_wif("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ")).to eql('0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d')
    end

    it "raises an error on bad checksum" do
      expect { @key.from_wif("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTBADTJ") }.to raise_error(MoneyTree::Key::InvalidWIFFormat)
    end
  end

  describe "to_base64" do
    it "has 44 characters" do
      expect(@key.to_base64.length).to eql(44)
    end

    it "is a valid base64" do
      expect(@key.to_base64).to eql('Xq5Tdftfeg6mUFZjY776KDDvRBvcsZGYrfMY+u6G1ks=')
    end
  end

  describe "from_base64(base64_key)" do
    it "parses base64 key" do
      @key = MoneyTree::PrivateKey.new(key: "Xq5Tdftfeg6mUFZjY776KDDvRBvcsZGYrfMY+u6G1ks=")
      expect(@key.to_hex).to eql("5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b")
    end

    it "returns the key from base64 encoding" do
      expect(@key.from_base64("Xq5Tdftfeg6mUFZjY776KDDvRBvcsZGYrfMY+u6G1ks=")).to eql('5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b')
    end

    it "raises an error on bad encoding" do
      expect { @key.from_base64("Xq5Tdftfeg6mUFZjY776KD&%#BbadBADrfMY+u6G1ks=") }.to raise_error(MoneyTree::Key::InvalidBase64Format)
    end
  end

  describe "valid?(eckey)" do
    it "checks for a valid key" do
      expect(@key.valid?).to be_truthy
    end
  end

  describe "parse_raw_key" do
    it "returns error if key is not Bignum, hex, base64, or wif formatted" do
      expect { @key = MoneyTree::PrivateKey.new(key: "Thisisnotakey") }.to raise_error(MoneyTree::Key::KeyFormatNotFound)
    end

    it "raises an error that can be caught using a standard exception block" do
      exception_raised = false

      begin
        MoneyTree::PrivateKey.new(key: "Thisisnotakey")
      rescue => ex
        exception_raised = true
      end
      fail unless exception_raised
    end
  end

  context "testnet" do
    before do
      @key = MoneyTree::PrivateKey.new key: 'cRhes8SBnsF6WizphaRKQKZZfDniDa9Bxcw31yKeEC1KDExhxFgD'
    end

    describe "to_wif" do
      it "returns same wif" do
        expect(@key.to_wif(network: :bitcoin_testnet)).to eql('cRhes8SBnsF6WizphaRKQKZZfDniDa9Bxcw31yKeEC1KDExhxFgD')
      end
    end
  end
end
