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
          extended_privkey_version: "0488ade4",
          extended_pubkey_version: "0488b21e",
          compressed_wif_chars: %w(K L),
          uncompressed_wif_chars: %w(5),
          protocol_version: 70001,
          human_readable_part: "bc",
        },
        bitcoin_testnet: {
          address_version: "6f",
          p2sh_version: "c4",
          p2sh_char: "2",
          privkey_version: "ef",
          privkey_compression_flag: "01",
          extended_privkey_version: "04358394",
          extended_pubkey_version: "043587cf",
          compressed_wif_chars: %w(c),
          uncompressed_wif_chars: %w(9),
          protocol_version: 70001,
          human_readable_part: "tb",
        },
      )
      hsh[:testnet3] = hsh[:bitcoin_testnet]
      hsh
    end
end
