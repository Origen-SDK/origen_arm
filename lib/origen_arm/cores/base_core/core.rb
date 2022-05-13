module OrigenARM
  module Cores
    class Base
      include Origen::Model
      attr_reader :cpu_wait_release

      def initialize(options = {})
        @cpu_wait_release = options[:cpu_wait_release]
      end

      #
      #       def mpu?
      #       end
      #
      #       def mcu?
      #       end
    end
  end
end
