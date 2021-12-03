require "openssl_extensions"
require "money-tree/version"
require "money-tree/support"
require "money-tree/networks"
require "money-tree/key"
require "money-tree/address"
require "money-tree/networks"
require "money-tree/node"

module MoneyTree
  DEFAULT_CURVE_NAME = 'secp256k1'
  DEFAULT_CURVE_ID = 714
  @curve_name = DEFAULT_CURVE_NAME
  @curve_id = DEFAULT_CURVE_ID

  def self.setCurve(name, id)
    @curve_name = name || DEFAULT_CURVE_NAME
    @curve_id = id || DEFAULT_CURVE_ID
  end

  def self.getCurve()
    { name: @curve_name, id: @curve_id }
  end
end
