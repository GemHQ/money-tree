require "money-tree/support"

require "money-tree/address"
require "money-tree/key"
require "money-tree/networks"
require "money-tree/node"
require "money-tree/version"

ENV["OPENSSL_CONF"] = File.expand_path(
  File.join(File.dirname(__FILE__), "..", "config", "openssl.conf")
)

require "openssl_extensions"

module MoneyTree; end
