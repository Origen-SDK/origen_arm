module OrigenARM
  module Cores
    module CortexM
      class Base < OrigenARM::Cores::Base
        require_relative 'cortexm_registers'

        include Origen::Model
        include Registers

        attr_reader :enter_debug_mode_delay_cycles
        attr_reader :exit_debug_mode_delay_cycles
        attr_reader :write_debug_register_delay
        attr_reader :read_debug_register_delay

        # Initialize the CortexM base.
        # @param [Hash] options CortexM Base options.
        # @option options [True, False] :no_init_common_registers Skip initializing common registers entirely.
        # @option options [Fixnum] :enter_debug_mode_delay_cycles
        #   Customize the delay (in cycles) to wait for the device to enter debug mode.
        # @option options [Fixnum] :exit_debug_mode_delay_cycles
        #   Customize the delay (in cycles) to wait for the device to exit debug mode.
        # @note For the most part, enter/exit debug mode delay cycles should be the same,
        #   so the same override will affect both. For these to be truely different,
        #   both options must be given.
        def initialize(options = {})
          # Initialize any common registers followed by the core's own registers.
          # Note that the core's #initialize_registers could re-configure or
          # remove any common registers that aren't actually common to that core.
          OrigenARM::Cores::CortexM::Base::Registers.instantiate_registers(self, options) unless options[:no_init_common_registers]
          instantiate_registers(options) if respond_to?(:instantiate_registers)

          @enter_debug_mode_delay_cycles = options[:enter_debug_mode_delay_cycles] || options[:exit_debug_mode_delay_cycles] || 50
          @exit_debug_mode_delay_cycles  = options[:exit_debug_mode_delay_cycles] || options[:enter_debug_mode_delay_cycles] || 50

          @write_debug_register_delay = options[:write_debug_register_delay] || 1000
          @read_debug_register_delay  = options[:read_debug_register_delay] || 1000

          super
        end

        # Returns the location of the <code>Registers</code> module.
        # @return [Module]
        # @example Retrieve the register scope of the CM33 core model.
        #   dut.cm33_core._registers_scope #=> OrigenARM::Cores::CortexM::CM33::Registers
        def _registers_scope
          eval("#{self.class}::Registers")
        end
      end
    end
  end
end
