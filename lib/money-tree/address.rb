module MoneyTree
  class Address
    attr_reader :private_key
    attr_reader :public_key

    def initialize(opts = {})
      private_key = opts.delete(:private_key)
      @private_key = PrivateKey.new({ key: private_key }.merge(opts))
      @public_key = PublicKey.new(@private_key, opts)
    end

    def to_s(network: :bitcoin)
      @public_key.to_s(network: network)
    end

    def to_bech32(network: :bitcoin)
      hrp = NETWORKS[network][:human_readable_part]
      witprog = to_ripemd160
      Support.to_serialized_bech32(hrp, witprog)
    end

    def to_p2wpkh_p2sh(network: :bitcoin)
      @public_key.to_p2wpkh_p2sh(network: network)
    end
  end
end
