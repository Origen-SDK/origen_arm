require_relative 'cm33_controller'

module OrigenARM
  module Cores
    module CortexM
      class CM33 < OrigenARM::Cores::CortexM::Base
        require_relative 'cm33_registers'
        include Registers

        def initialize(options = {})
          super
        end
      end
    end
  end
end
