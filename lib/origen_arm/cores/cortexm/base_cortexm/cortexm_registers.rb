module OrigenARM
  module Cores
    module CortexM
      class Base
        # The CortexM base registers. Ideally, everything here will be applicable
        # to all Cortex M-Series cores.
        # @note The information referenced in this file was taken from the readily-available
        #   online ARM documentation and is included here as a resource for developers.
        #   See http://infocenter.arm.com/help/index.jsp for the original source.
        #   This source can also be downloaded from https://developer.arm.com/ and selecting
        #   'technical support' (login required).
        module Registers
          # Instantiates the CortexM base registers.
          # These registers should be applicable to all CortexM cores.
          #
          # @note This is purposefully a class method to avoid overwriting
          #   the core's own <code>#inititalize_registers</code> method.
          # @note <b>Extension Note:</b> The registers instantiated here can be post-processed
          #   if there are slight differences from core to core, rather than adding options here,
          #   reimplementing the method, or skipping the method entirely.
          def self.instantiate_registers(dut, options = {})
            # Any common registers can go here
            instantiate_core_registers(dut, options)
          end

          # Instantiates general purpose core registers. These are mostly stable
          # across all cortexM devices. Larger difference come into play on
          # implementation details (e.g., does the core license include the FPU?)
          #
          # @todo This is only a subset of the core registers. Need to add the remaining as they're needed.
          # @note None of these registers are directly accessible. These registers must go through the
          #   <code>DCRDR</code> and <code>DCRSR</code> registers with the <code>regsel</code> set appropriately.
          # @note The base address of these registers correspond to the of <code>regsel</code> value needed to access
          #   this register.
          def self.instantiate_core_registers(dut, options = {})
            dut.add_reg(:reg0, 0x0, size: 32, description: 'General Purpose Register 0')
            dut.add_reg(:reg1, 0x1, size: 32, description: 'General Purpose Register 1')
            dut.add_reg(:reg2, 0x2, size: 32, description: 'General Purpose Register 2')
            dut.add_reg(:reg3, 0x3, size: 32, description: 'General Purpose Register 3')
            dut.add_reg(:reg4, 0x4, size: 32, description: 'General Purpose Register 4')
            dut.add_reg(:reg5, 0x5, size: 32, description: 'General Purpose Register 5')
            dut.add_reg(:reg6, 0x6, size: 32, description: 'General Purpose Register 6')
            dut.add_reg(:reg7, 0x7, size: 32, description: 'General Purpose Register 7')

            dut.reg(:reg0).meta[:general_purpose_register] = true
            dut.reg(:reg1).meta[:general_purpose_register] = true
            dut.reg(:reg2).meta[:general_purpose_register] = true
            dut.reg(:reg3).meta[:general_purpose_register] = true
            dut.reg(:reg4).meta[:general_purpose_register] = true
            dut.reg(:reg5).meta[:general_purpose_register] = true
            dut.reg(:reg6).meta[:general_purpose_register] = true
            dut.reg(:reg7).meta[:general_purpose_register] = true

            # Current Stack Pointer
            dut.add_reg(:sp, 0xD, size: 32, description:
              [
                'The Current Stack Pointer.',
                'The exact stack pointer this points to will change in the hardware depending on the mode, security, etc.',
                'This will, however, always point to the current stack pointer in use.'
              ].join("\n")
                       )
            dut.reg(:sp).meta[:special_purpose_register] = true

            # Link Register
            dut.add_reg(:lr, 0xE, size: 32, description: 'The Current Linker Register')
            dut.reg(:lr).meta[:special_purpose_register] = true

            # Debug Return Address (Return PC)
            dut.add_reg(:debug_return_address, 0xF, size: 32, description:
              'Indicates the new program counter to be loaded after a successful vector catch occurs'
                       )
            dut.reg(:debug_return_address).meta[:special_purpose_register] = true

            # XPSR
            # Note: This register also seems mostly stable across the entire
            # CortexM family, but may need to be revisited as more cores are added.
            dut.add_reg(:xpsr, 0x10, size: 32, description: 'Combined Program Status Register. Combination of APSR, EPSR, and IPSR Registers on Other ARM Cores.') do |r|
              r.bits 31, :n, description: 'Negative flag. Reads or writes the current value of APSR.N.'
              r.bits 30, :z, description: 'Zero flag. Reads or writes the current value of APSR.Z.'
              r.bits 29, :c, description: 'Carry flag. Reads or writes the current value of APSR.C.'
              r.bits 28, :v, description: 'Overflow flag. Reads or writes the current value of APSR.V.'
              r.bits 27, :q, description: 'Saturate flag. Reads or writes the current value of APSR.Q.'
              r.bits 26..25, :upper_it_ici, description:
                [
                  'Note: this register is split between this field and the :lower_it_ici bits',

                  'When XPSR[:exception][11:10] != 0:',
                  '  Function as IT -> If-then Flags:',
                  '    If-then flags. Reads or writes the current value of EPSR.IT.',

                  'When XPSR[:exception][11:10] == 0:',
                  '  Function as ICI -> Interrupt Continuation Flags:',
                  '    Interrupt continuation flags. Reads or writes the current value of EPSR.ICI.'
                ].join("\n")
              r.bits 24, :t, description: 'T32 state. Reads or writes the current value of EPSR.T.'
              r.bits 23..20, :reserved, reset: 0
              r.bits 19..16, :ge, description: 'Greater-than or equal flag. Reads or writes the current value of APSR.GE.'
              r.bits 15..10, :lower_it_ici, description:
                [
                  'Note: this register is split between this field and the :upper_it_ici bits',

                  'When XPSR[:exception][11:10] != 0:',
                  '  Function as IT -> If-then Flags:',
                  '    If-then flags. Reads or writes the current value of EPSR.IT.',

                  'When XPSR[:exception][11:10] == 0:',
                  '  Function as ICI -> Interrupt Continuation Flags:',
                  '    Interrupt continuation flags. Reads or writes the current value of EPSR.ICI.'
                ].join("\n")
              r.bits 9, :reserved, reset: 0
              r.bits 8..0, :exception, description: 'Exception number. Reads or writes the current value of IPSR.Exception.'
            end
            dut.reg(:xpsr).meta[:special_purpose_register] = true
          end

          # Any other common methods regarding registers can go here.
        end
      end
    end
  end
end
