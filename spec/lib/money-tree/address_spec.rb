require 'spec_helper'

describe MoneyTree::Address do
  describe "initialize" do
    it "generates a private key by default" do
      address = MoneyTree::Address.new
      expect(address).to be
      expect(address).to be_instance_of MoneyTree::Address
      expect(address.private_key).to be_instance_of MoneyTree::PrivateKey
      expect(address.private_key.key.length).to eql(64)
    end

    it "generates a public key by default" do
      address = MoneyTree::Address.new
      expect(address).to be
      expect(address).to be_instance_of MoneyTree::Address
      expect(address.public_key).to be_instance_of MoneyTree::PublicKey
      expect(address.public_key.key.length).to eql(66)
    end

    it "imports a private key in hex form" do
      address = MoneyTree::Address.new private_key: "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
      expect(address.private_key.key).to eql("5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b")
      expect(address.public_key.key).to eql("022dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b")
      expect(address.to_s).to eql("13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe")
      expect(address.private_key.to_s).to eql("KzPkwAXJ4wtXHnbamTaJqoMrzwCUUJaqhUxnqYhnZvZH6KhgmDPK")
      expect(address.public_key.to_s).to eql("13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe")
    end

    it "imports a private key in compressed wif format" do
      address = MoneyTree::Address.new private_key: "KzPkwAXJ4wtXHnbamTaJqoMrzwCUUJaqhUxnqYhnZvZH6KhgmDPK"
      expect(address.private_key.key).to eql("5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b")
      expect(address.public_key.key).to eql("022dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b")
      expect(address.to_s).to eql("13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe")
    end

    it "imports a private key in uncompressed wif format" do
      address = MoneyTree::Address.new private_key: "5JXz5ZyFk31oHVTQxqce7yitCmTAPxBqeGQ4b7H3Aj3L45wUhoa"
      expect(address.private_key.key).to eql("5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b")
      expect(address.public_key.key).to eql("022dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b")
    end
  end

  describe "to_s" do
    before do
      @address = MoneyTree::Address.new private_key: "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
    end

    it "returns compressed base58 public key" do
      expect(@address.to_s).to eql("13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe")
      expect(@address.public_key.to_s).to eql("13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe")
    end

    it "returns compressed WIF private key" do
      expect(@address.private_key.to_s).to eql("KzPkwAXJ4wtXHnbamTaJqoMrzwCUUJaqhUxnqYhnZvZH6KhgmDPK")
    end
  end

  context "testnet3" do
    before do
      @address = MoneyTree::Address.new network: :bitcoin_testnet
    end

    it "returns a testnet address" do
      expect(%w(m n)).to include(@address.to_s(network: :bitcoin_testnet)[0])
    end
  end
end
