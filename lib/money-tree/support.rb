require "base64"
require "bech32"
require "openssl"

module MoneyTree
  module Support
    include OpenSSL

    INT32_MAX = 256 ** [1].pack("L*").size
    INT64_MAX = 256 ** [1].pack("Q*").size
    BASE58_CHARS = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    def int_to_base58(int_val, leading_zero_bytes = 0)
      base58_val, base = "", BASE58_CHARS.size
      while int_val > 0
        int_val, remainder = int_val.divmod(base)
        base58_val = BASE58_CHARS[remainder] + base58_val
      end
      base58_val
    end

    def base58_to_int(base58_val)
      int_val, base = 0, BASE58_CHARS.size
      base58_val.reverse.each_char.with_index do |char, index|
        raise ArgumentError, "Value not a valid Base58 String." unless char_index = BASE58_CHARS.index(char)
        int_val += char_index * (base ** index)
      end
      int_val
    end

    def encode_base58(hex)
      leading_zero_bytes = (hex.match(/^([0]+)/) ? $1 : "").size / 2
      ("1" * leading_zero_bytes) + int_to_base58(hex.to_i(16))
    end

    def decode_base58(base58_val)
      s = base58_to_int(base58_val).to_s(16); s = (s.bytesize.odd? ? "0" + s : s)
      s = "" if s == "00"
      leading_zero_bytes = (base58_val.match(/^([1]+)/) ? $1 : "").size
      s = ("00" * leading_zero_bytes) + s if leading_zero_bytes > 0
      s
    end

    alias_method :base58_to_hex, :decode_base58

    def to_serialized_base58(hex)
      hash = sha256 hex
      hash = sha256 hash
      checksum = hash.slice(0..7)
      address = hex + checksum
      encode_base58 address
    end

    def to_serialized_bech32(human_readable_part, hex)
      segwit_addr = Bech32::SegwitAddr.new
      segwit_addr.hrp = human_readable_part
      segwit_addr.script_pubkey = "0000" + hex
      segwit_addr.addr
    end

    def from_serialized_base58(base58)
      hex = decode_base58 base58
      checksum = hex.slice!(-8..-1)
      compare_checksum = sha256(sha256(hex)).slice(0..7)
      raise EncodingError unless checksum == compare_checksum
      hex
    end

    def digestify(digest_type, source, opts = {})
      source = [source].pack("H*") unless opts[:ascii]
      bytes_to_hex Digest.digest(digest_type, source)
    end

    def sha256(source, opts = {})
      digestify("SHA256", source, opts)
    end

    def ripemd160(source, opts = {})
      digestify("RIPEMD160", source, opts)
    end

    def encode_base64(hex)
      Base64.encode64([hex].pack("H*")).chomp
    end

    def decode_base64(base64)
      Base64.decode64(base64).unpack("H*")[0]
    end

    def hmac_sha512(key, message)
      digest = Digest::SHA512.new
      HMAC.digest digest, key, message
    end

    def hmac_sha512_hex(key, message)
      md = hmac_sha512(key, message)
      md.unpack("H*").first.rjust(64, "0")
    end

    def bytes_to_int(bytes, base = 16)
      if bytes.is_a?(Array)
        bytes = bytes.pack("C*")
      end
      bytes.unpack("H*")[0].to_i(16)
    end

    def int_to_hex(i, size = nil)
      hex = i.to_s(16).downcase
      if (hex.size % 2) != 0
        hex = "#{0}#{hex}"
      end

      if size
        hex.rjust(size, "0")
      else
        hex
      end
    end

    def int_to_bytes(i)
      [int_to_hex(i)].pack("H*")
    end

    def bytes_to_hex(bytes)
      bytes.unpack("H*")[0].downcase
    end

    def hex_to_bytes(hex)
      [hex].pack("H*")
    end

    def hex_to_int(hex)
      hex.to_i(16)
    end

    def encode_p2wpkh_p2sh(value)
      chk = [Digest::SHA256.hexdigest(Digest::SHA256.digest(value))].pack("H*")[0...4]
      encode_base58 (value + chk).unpack("H*")[0]
    end

    def custom_hash_160(value)
      [OpenSSL::Digest::RIPEMD160.hexdigest(Digest::SHA256.digest(value))].pack("H*")
    end

    def convert_p2wpkh_p2sh(key_hex, prefix)
      push_20 = ["0014"].pack("H*")
      script_sig = push_20 + custom_hash_160([key_hex].pack("H*"))
      encode_p2wpkh_p2sh(prefix + custom_hash_160(script_sig))
    end
  end
end
