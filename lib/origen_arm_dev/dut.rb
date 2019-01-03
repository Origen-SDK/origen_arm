module OrigenARMDev
  # This is a dummy DUT class that should be used to test that your test module can
  # integrate into a top-level app
  class DUT
    include Origen::TopLevel
    include OrigenJTAG
    include OrigenARMDebug

    def initialize(options = {})
      instantiate_pins(options)
      instantiate_sub_blocks(options)
    end

    def instantiate_pins(options)
      add_pin :tclk
      add_pin :tdi
      add_pin :tdo
      add_pin :tms
      add_pin :resetb
    end

    def instantiate_sub_blocks(options)
      sub_block :arm_debug, class_name: 'OrigenARMDebug::DAP', mem_aps: { mem_ap: 0x0, mdmap: 0x0100_0000 }
      sub_block :cm33, class_name: 'OrigenARM::Cores::CortexM::CM33', base_address: 0x1000_0000
    end
  end
end
