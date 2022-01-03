module MoneyTree
  class Address
    attr_reader :private_key, :public_key

    def initialize(opts = {})
      private_key = opts.delete(:private_key)
      @private_key = MoneyTree::PrivateKey.new({ key: private_key }.merge(opts))
      @public_key = MoneyTree::PublicKey.new(@private_key, opts)
    end

    def to_s(network: :bitcoin)
      public_key.to_s(network: network)
    end
    
    def to_p2wpkh_p2sh(network: :bitcoin)
      public_key.to_p2wpkh_p2sh(network: network)
    end

  end
end
