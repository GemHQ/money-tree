module MoneyTree
  NETWORKS =
    begin
      hsh = Hash.new do |_, key|
        raise "#{key} is not a valid network!"
      end.merge(
        bitcoin: {
          address_version: '00',
          p2sh_version: '05',
          p2sh_char: '3',
          privkey_version: '80',
          privkey_compression_flag: '01',
          extended_privkey_version: "0488ade4",
          extended_pubkey_version: "0488b21e",
          compressed_wif_chars: %w(K L),
          uncompressed_wif_chars: %w(5),
          protocol_version: 70001
        },
        bitcoin_testnet: {
          address_version: '6f',
          p2sh_version: 'c4',
          p2sh_char: '2',
          privkey_version: 'ef',
          privkey_compression_flag: '01',
          extended_privkey_version: "04358394",
          extended_pubkey_version: "043587cf",
          compressed_wif_chars: %w(c),
          uncompressed_wif_chars: %w(9),
          protocol_version: 70001
        },
        litecoin: {
          address_version: '30',
          p2sh_version: '32',
          p2sh_char: '3',##TODO
          privkey_version: 'b0',
          privkey_compression_flag: '01',##TODO
          extended_privkey_version: "019d9cfe",
          extended_pubkey_version: "019da462",
          compressed_wif_chars: %w(K L),##TODO
          uncompressed_wif_chars: %w(5),##TODO
          protocol_version: 70002
        },
        litecoin_testnet: {
          address_version: '6f',
          p2sh_version: '3a',
          p2sh_char: '2',##TODO
          privkey_version: 'ef',
          privkey_compression_flag: '01',##TODO
          extended_privkey_version: "0436ef7d",
          extended_pubkey_version: "0436f6e1",
          compressed_wif_chars: %w(c),##TODO
          uncompressed_wif_chars: %w(9),##TODO
          protocol_version: 70002
        },
        dash: {
          address_version: '4c', # this makes the Y
          p2sh_version: '10',
          p2sh_char: '2',
          privkey_version: 'cc',
          privkey_compression_flag: '01',
          extended_privkey_version: "04358394", #default BTC
          extended_pubkey_version: "043587cf", #default BTC
          compressed_wif_chars: %w(c),
          uncompressed_wif_chars: %w(9),
          protocol_version: 70014
        },
        dash_testnet: {
          address_version: '8c', # this makes the X
          p2sh_version: '13',
          p2sh_char: '2',
          privkey_version: 'ef',
          privkey_compression_flag: '01',
          extended_privkey_version: "04358394", #default BTC
          extended_pubkey_version: "043587cf", #default BTC
          compressed_wif_chars: %w(c),
          uncompressed_wif_chars: %w(9),
          protocol_version: 70014
        }

      )
      hsh[:testnet3] = hsh[:bitcoin_testnet]
      hsh
    end
end
