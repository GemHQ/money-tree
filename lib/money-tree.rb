require "openssl_extensions"
require 'money-tree/configuration'
require "money-tree/version"
require "money-tree/support"
require "money-tree/networks"
require "money-tree/key"
require "money-tree/address"
require "money-tree/networks"
require "money-tree/node"

module MoneyTree
  class << self
     attr_accessor :configuration
   end

   def self.network
     configuration.network
   end

   def self.configuration
     @configuration ||= Configuration.new
   end

   def self.reset
     @configuration = Configuration.new
   end

   def self.configure
     yield(configuration)
   end
end
