module OrigenARM
  module Cores
    class BaseController
      include Origen::Controller

      def initialize(options = {})
      end
=begin
      def halt!(options={})
      end
      
      def release!(options={})
      end
      
      def set_pc!(pc, options={})
      end
      
      def set_sp!(sp, options={})
      end
      
      def with_debug_mode(options={}, &block)
      end
      
      def initialize_core(pc: nil, sp: nil, **options)
      end
=end
    end
  end
end
