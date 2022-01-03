module MoneyTree
  class Node
    include Support
    extend Support

    attr_reader :private_key
    attr_reader :public_key
    attr_reader :chain_code
    attr_reader :is_private
    attr_reader :depth
    attr_reader :index
    attr_reader :parent

    class PublicDerivationFailure < StandardError; end
    class InvalidKeyForIndex < StandardError; end
    class ImportError < StandardError; end
    class PrivatePublicMismatch < StandardError; end

    def initialize(opts = {})
      opts.each { |k, v| instance_variable_set "@#{k}", v }
    end

    def self.from_bip32(address, has_version: true)
      hex = from_serialized_base58 address
      hex.slice!(0..7) if has_version
      self.new({
        depth: hex.slice!(0..1).to_i(16),
        parent_fingerprint: hex.slice!(0..7),
        index: hex.slice!(0..7).to_i(16),
        chain_code: hex.slice!(0..63).to_i(16),
      }.merge(parse_out_key(hex)))
    end

    def self.from_serialized_address(address)
      puts "Node.from_serialized_address is DEPRECATED. Please use .from_bip32 instead."
      from_bip32(address)
    end

    def self.parse_out_key(hex)
      if hex.slice(0..1) == "00"
        private_key = MoneyTree::PrivateKey.new(key: hex.slice(2..-1))
        {
          private_key: private_key,
          public_key: MoneyTree::PublicKey.new(private_key),
        }
      elsif %w(02 03).include? hex.slice(0..1)
        { public_key: MoneyTree::PublicKey.new(hex) }
      else
        raise ImportError, "Public or private key data does not match version type"
      end
    end

    def is_private?
      index >= 0x80000000 || index < 0
    end

    def index_hex(i = index)
      if i < 0
        [i].pack("l>").unpack("H*").first
      else
        i.to_s(16).rjust(8, "0")
      end
    end

    def depth_hex(depth)
      depth.to_s(16).rjust(2, "0")
    end

    def private_derivation_message(i)
      "\x00" + private_key.to_bytes + i_as_bytes(i)
    end

    def public_derivation_message(i)
      public_key.to_bytes << i_as_bytes(i)
    end

    def i_as_bytes(i)
      [i].pack("N")
    end

    def derive_private_key(i = 0)
      message = i >= 0x80000000 || i < 0 ? private_derivation_message(i) : public_derivation_message(i)
      hash = hmac_sha512 hex_to_bytes(chain_code_hex), message
      left_int = left_from_hash(hash)
      raise InvalidKeyForIndex, "greater than or equal to order" if left_int >= MoneyTree::Key::ORDER # very low probability
      child_private_key = (left_int + private_key.to_i) % MoneyTree::Key::ORDER
      raise InvalidKeyForIndex, "equal to zero" if child_private_key == 0 # very low probability
      child_chain_code = right_from_hash(hash)
      return child_private_key, child_chain_code
    end

    def derive_public_key(i = 0)
      raise PrivatePublicMismatch if i >= 0x80000000
      message = public_derivation_message(i)
      hash = hmac_sha512 hex_to_bytes(chain_code_hex), message
      left_int = left_from_hash(hash)
      raise InvalidKeyForIndex, "greater than or equal to order" if left_int >= MoneyTree::Key::ORDER # very low probability
      factor = BN.new left_int.to_s

      gen_point = public_key.uncompressed.group.generator.mul(factor)

      sum_point_hex = MoneyTree::OpenSSLExtensions.add(gen_point, public_key.uncompressed.point)
      child_public_key = OpenSSL::PKey::EC::Point.new(public_key.group, OpenSSL::BN.new(sum_point_hex, 16)).to_bn.to_i

      raise InvalidKeyForIndex, "at infinity" if child_public_key == 1 / 0.0 # very low probability
      child_chain_code = right_from_hash(hash)
      return child_public_key, child_chain_code
    end

    def left_from_hash(hash)
      bytes_to_int hash.bytes.to_a[0..31]
    end

    def right_from_hash(hash)
      bytes_to_int hash.bytes.to_a[32..-1]
    end

    def to_serialized_hex(type = :public, network: :bitcoin)
      raise PrivatePublicMismatch if type.to_sym == :private && private_key.nil?
      version_key = type.to_sym == :private ? :extended_privkey_version : :extended_pubkey_version
      hex = NETWORKS[network][version_key] # version (4 bytes)
      hex += depth_hex(depth) # depth (1 byte)
      hex += parent_fingerprint # fingerprint of key (4 bytes)
      hex += index_hex(index) # child number i (4 bytes)
      hex += chain_code_hex
      hex += type.to_sym == :private ? "00#{private_key.to_hex}" : public_key.compressed.to_hex
    end

    def to_bip32(type = :public, network: :bitcoin)
      raise PrivatePublicMismatch if type.to_sym == :private && private_key.nil?
      to_serialized_base58 to_serialized_hex(type, network: network)
    end

    def to_serialized_address(type = :public, network: :bitcoin)
      puts "Node.to_serialized_address is DEPRECATED. Please use .to_bip32."
      to_bip32(type, network: network)
    end

    def to_identifier(compressed = true)
      key = compressed ? public_key.compressed : public_key.uncompressed
      key.to_ripemd160
    end

    def to_fingerprint
      public_key.compressed.to_fingerprint
    end

    def parent_fingerprint
      if @parent_fingerprint
        @parent_fingerprint
      else
        depth.zero? ? "00000000" : parent.to_fingerprint
      end
    end

    def to_address(compressed = true, network: :bitcoin)
      address = NETWORKS[network][:address_version] + to_identifier(compressed)
      to_serialized_base58 address
    end

    def to_p2wpkh_p2sh(network: :bitcoin)
      public_key.to_p2wpkh_p2sh(network: network)
    end

    def to_bech32_address(network: :bitcoin)
      hrp = NETWORKS[network][:human_readable_part]
      witprog = to_identifier
      to_serialized_bech32(hrp, witprog)
    end

    def subnode(i = 0, opts = {})
      if private_key.nil?
        child_public_key, child_chain_code = derive_public_key(i)
        child_public_key = MoneyTree::PublicKey.new child_public_key
      else
        child_private_key, child_chain_code = derive_private_key(i)
        child_private_key = MoneyTree::PrivateKey.new key: child_private_key
        child_public_key = MoneyTree::PublicKey.new child_private_key
      end

      MoneyTree::Node.new(depth: depth + 1,
                          index: i,
                          private_key: private_key.nil? ? nil : child_private_key,
                          public_key: child_public_key,
                          chain_code: child_chain_code,
                          parent: self)
    end

    # path: a path of subkeys denoted by numbers and slashes. Use
    #     p or i<0 for private key derivation. End with .pub to force
    #     the key public.
    #
    # Examples:
    #     1p/-5/2/1 would call subkey(i=1, is_prime=True).subkey(i=-5).
    #         subkey(i=2).subkey(i=1) and then yield the private key
    #     0/0/458.pub would call subkey(i=0).subkey(i=0).subkey(i=458) and
    #         then yield the public key
    #
    # You should choose either the p or the negative number convention for private key derivation.
    def node_for_path(path)
      force_public = path[-4..-1] == ".pub"
      path = path[0..-5] if force_public
      parts = path.split("/")
      nodes = []
      parts.each_with_index do |part, depth|
        if part =~ /m/i
          nodes << self
        else
          i = parse_index(part)
          node = nodes.last || self
          nodes << node.subnode(i)
        end
      end
      if force_public or parts.first == "M"
        node = nodes.last
        node.strip_private_info!
        node
      else
        nodes.last
      end
    end

    def parse_index(path_part)
      is_prime = %w(p ').include? path_part[-1]
      i = path_part.to_i

      i = if i < 0
          i
        elsif is_prime
          i | 0x80000000
        else
          i & 0x7fffffff
        end
    end

    def strip_private_info!
      @private_key = nil
    end

    def chain_code_hex
      int_to_hex chain_code, 64
    end
  end

  class Master < Node
    module SeedGeneration
      class Failure < Exception; end
      class RNGFailure < Failure; end
      class LengthFailure < Failure; end
      class ValidityError < Failure; end
      class ImportError < Failure; end
      class TooManyAttempts < Failure; end
    end

    HD_WALLET_BASE_KEY = "Bitcoin seed"
    RANDOM_SEED_SIZE = 32

    attr_reader :seed, :seed_hash

    def initialize(opts = {})
      @depth = 0
      @index = 0
      opts[:seed] = [opts[:seed_hex]].pack("H*") if opts[:seed_hex]
      if opts[:seed]
        @seed = opts[:seed]
        @seed_hash = generate_seed_hash(@seed)
        raise SeedGeneration::ImportError unless seed_valid?(@seed_hash)
        set_seeded_keys
      elsif opts[:private_key] || opts[:public_key]
        raise ImportError, "chain code required" unless opts[:chain_code]
        @chain_code = opts[:chain_code]
        if opts[:private_key]
          @private_key = opts[:private_key]
          @public_key = MoneyTree::PublicKey.new @private_key
        else opts[:public_key]
          @public_key = if opts[:public_key].is_a?(MoneyTree::PublicKey)
            opts[:public_key]
          else
            MoneyTree::PublicKey.new(opts[:public_key])
          end         end
      else
        generate_seed
        set_seeded_keys
      end
    end

    def is_private?
      true
    end

    def generate_seed
      @seed = OpenSSL::Random.random_bytes(32)
      @seed_hash = generate_seed_hash(@seed)
      raise SeedGeneration::ValidityError unless seed_valid?(@seed_hash)
    end

    def generate_seed_hash(seed)
      hmac_sha512 HD_WALLET_BASE_KEY, seed
    end

    def seed_valid?(seed_hash)
      return false unless seed_hash.bytesize == 64
      master_key = left_from_hash(seed_hash)
      !master_key.zero? && master_key < MoneyTree::Key::ORDER
    end

    def set_seeded_keys
      @private_key = MoneyTree::PrivateKey.new key: left_from_hash(seed_hash)
      @chain_code = right_from_hash(seed_hash)
      @public_key = MoneyTree::PublicKey.new @private_key
    end

    def seed_hex
      bytes_to_hex(seed)
    end
  end
end
