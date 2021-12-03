module MoneyTree
  class Configuration
   attr_accessor :network

   def initialize(args={})
     @network = args.delete(:network) || :bitcoin
   end
 end
end
