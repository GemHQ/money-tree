module MoneyTree
  NETWORKS = begin
      hsh = Hash.new do |_, key|
        raise "#{key} is not a valid network!"
      end.merge(
        bitcoin: {
          address_version: "00",
          p2sh_version: "05",
          p2sh_char: "3",
          privkey_version: "80",
          privkey_compression_flag: "01",
          extended_version: {
            public: {
              bip_44:	'0x0488b21e',
              bip_49:	'0x049d7cb2',
              bip_84:	'0x04b24746'
            },
            private: {
              bip_44:	'0x0488ade4',
              bip_49:	'0x049d7878',
              bip_84:	'0x04b2430c'
            }
          },
          compressed_wif_chars: %w(K L),
          uncompressed_wif_chars: %w(5),
          protocol_version: 70001,
          human_readable_part: "bc"
        },
        bitcoin_testnet: {
          address_version: "6f",
          p2sh_version: "c4",
          p2sh_char: "2",
          privkey_version: "ef",
          privkey_compression_flag: "01",
          extended_version: {
            public: {
              bip_44:	'0x043587cf',
              bip_49:	'0x044a5262',
              bip_84:	'0x045f1cf6'
            },
            private: {
              bip_44:	'0x04358394',
              bip_49:	'0x044a4e28',
              bip_84:	'0x045f18bc'
            }
          },
          compressed_wif_chars: %w(c),
          uncompressed_wif_chars: %w(9),
          protocol_version: 70001,
          human_readable_part: "tb"
        },
      )
      hsh[:testnet3] = hsh[:testnet4] = hsh[:regtest] = hsh[:bitcoin_testnet]
      hsh
    end
end
