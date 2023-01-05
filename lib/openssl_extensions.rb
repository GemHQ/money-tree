# encoding: ascii-8bit

require "openssl"

module MoneyTree
  module OpenSSLExtensions
    extend self

    def add(point_0, point_1)
      validate_points(point_0, point_1)
      group = OpenSSL::PKey::EC::Group.new("secp256k1")
      point_0_hex = point_0.to_bn.to_s(16)
      point_0_pt = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(point_0_hex, 16))
      point_1_hex = point_1.to_bn.to_s(16)
      point_1_pt = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(point_1_hex, 16))
      sum_point = point_0_pt.add(point_1_pt)
      sum_point.to_bn.to_s(16)
    end

    def validate_points(*points)
      points.each do |point|
        if !point.is_a?(OpenSSL::PKey::EC::Point)
          raise ArgumentError, "point must be an OpenSSL::PKey::EC::Point object"
        elsif point.infinity?
          raise ArgumentError, "point must not be infinity"
        end
      end
    end
  end
end
