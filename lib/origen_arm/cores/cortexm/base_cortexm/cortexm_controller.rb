module OrigenARM
  module Cores
    module CortexM
      class BaseController < OrigenARM::Cores::BaseController
        include Origen::Controller

        def initialize(options = {})
          super
        end

        # Delays for the core to to enter debug mode.
        # @note The delay (in cycles) can be set by initializing the core
        #   subblock parameter <code>:enter_debug_mode_delay_cycles</code>.
        # @note If the <code>DUT</code> provides the same method, that method
        #   will be used in place of this one.
        def enter_debug_mode_delay!
          if dut.respond_to?('enter_debug_mode_delay!'.to_sym)
            cc 'Using DUT-defined #enter_debug_mode_delay! for core to enter debug mode'
            dut.enter_debug_mode_delay!
          else
            cc "Delaying #{enter_debug_mode_delay_cycles} cycles for core to enter debug mode"
            tester.cycle(repeat: enter_debug_mode_delay_cycles)
          end
        end

        # Delays for the core to to exit debug mode.
        # @note The delay (in cycles) can be set by initializing the core
        #   subblock parameter <code>:exit_debug_mode_delay_cycles</code>.
        # @note If the <code>DUT</code> provides the same method, that method
        #   will be used in place of this one.
        def exit_debug_mode_delay!
          if dut.respond_to?('exit_debug_mode_delay!'.to_sym)
            cc 'Using DUT-defined #exit_debug_mode_delay! for core to exit debug mode'
            dut.exit_debug_mode_delay!
          else
            cc "Delaying #{exit_debug_mode_delay_cycles} cycles for core to exit debug mode"
            tester.cycle(repeat: exit_debug_mode_delay_cycles)
          end
        end

        # Runs the given block in debug mode, exiting debug mode upon completion.
        # @param with_core_halted [true, false] Indicates if the core should be halted while executing the given blocck.
        #   If true, the core will be released upon debug mode exit.
        # @note This is equivalent to: <br>
        #   -> <code>enter_debug_mode(halt_core: with_core_halted)</code> <br>
        #   -> <code>...</code> <br>
        #   -> <code>exit_debug_mode(release_core: with_core_halted)</code>
        # @example Perform a write/read-expect operation on <code>dut.core(:reg1)</code>
        #   dut.core.in_debug_mode do
        #     dut.core.reg(:reg7).write!(0x7)
        #     dut.core.reg(:reg7).read!(0x7)
        #   end
        def in_debug_mode(with_core_halted: false)
          enter_debug_mode(halt_core: with_core_halted)
          yield
          exit_debug_mode(release_core: with_core_halted)
        end
        alias_method :with_debug_mode, :in_debug_mode
        alias_method :with_debug_enabled, :in_debug_mode

        # Certain registers within the core must be written in certain ways.
        # Override the <code>reg.read!</code> and <code>reg.write!</code> methods to have Origen handle this.
        # @note This doesn't protect from the user copying the register to a different namepace,
        #   nor from using the address directly.
        # @note This method will use the toplevel's <code>reg.write!</code>.
        #   This is just wraps the write process for certain registers.
        # @see Link: <a href='https://origen-sdk.org/origen/guides/pattern/registers/#Basic_Concept'>Registers Docs</a>
        def write_register(reg, options = {})
          if reg_wrapped_by_dcrsr?(reg)
            # This register write requires a few steps:
            # 1. Write the dcrdr register with the data.
            #
            # 2a. Write the dcrsr[:regwnr] bit to 1 (indicate a write)
            # 2b. Write the regsel bits with the desired register.
            # (The above two take place in a single transaction)
            #
            # Writing the dcrsr will trigger the write to occur. Very important
            # the write to the dcrdr occurs first.
            #
            # This requires a reg_sel lookup.
            pp("Writing Debug Register: #{reg.name} <- #{reg.data.to_hex}") do
              reg(:dcrdr).write!(reg.data)
              reg(:dcrsr).bits(:regwnr).write(1)
              reg(:dcrsr).bits(:reg_sel).write(reg.address)
              reg(:dcrsr).write!
              tester.cycle(repeat: write_debug_register_delay)
            end
          else
            # Nothing special about this registers. Write it as normal.
            parent.write_register(reg, options)
          end
        end

        # Certain registers within the core must be written in certain ways.
        # Override the <code>reg.read!</code> and <code>reg.write!</code> methods to have Origen handle this.
        # @note This doesn't protect from the user copying the register to a different namepace,
        #   nor from using the address directly.
        # @note This method will use the toplevel's <code>reg.read!</code>.
        #   This is just wraps the write process for certain registers.
        # @see Link: <a href='https://origen-sdk.org/origen/guides/pattern/registers/#Basic_Concept'>Registers Docs</a>
        def read_register(reg, options = {})
          if reg_wrapped_by_dcrsr?(reg)
            pp("Reading and Comparing Core Register: DCRDR <- #{reg.name}.data (expecting #{reg.data}") do
              core_reg_to_dcrdr(reg, options)
              reg(:dcrdr).read!(reg.data)
            end
          else
            # Nothing special about this registers. Write it as normal.
            parent.read_register(reg, options)
          end
        end

        # Reads the core register and places its contents in the DCRDR, but does
        # not invoke and tester-level compares.
        # @note This is a shortcut to a <code>reg.read!</code> call that masks all the bits.
        # @todo Implement <code>Raise</code> condition.
        # @raise [OrigenARM::CoreRegisterError] If <code>reg</code> is not a core register.
        # @note See the implementation of #write_register for additional details on the internals.
        # @note All core registers are 32-bits. Any contents in the DCRDR will be overwritten.
        def core_reg_to_dcrdr(reg, options)
          if reg_wrapped_by_dcrsr?(reg)
            pp("Copying Core Register to DCRDR: DCRDR <- #{reg.name}.data") do
              reg(:dcrsr).bits(:regwnr).write(0)
              reg(:dcrsr).bits(:reg_sel).write(reg.address)
              reg(:dcrsr).write!
              tester.cycle(repeat: read_debug_register_delay)
            end
          else
            Origen.app.fail!(
              message:   'Method #core_reg_to_dcrdr can only be run with the core debug registers. ' \
                       "Given register #{reg.is_a?(Register) ? reg.name : reg.to_s} is not classified as a core register.",
              exception: OrigenARM::CoreRegisterError
            )
          end
        end

        # Checks if the register given is either a <code>general_purpose_register</code>, <code>special_purpose_register</code>,
        # or a <code>floating_point_register</code>. <br> <br> Read and writes to these regsters are wrapped around the
        # <code>DHRCR</code> and <code>DHRSR</code> registers.
        # @raise NoRegisterError If <code>reg</code> could not be converted to a register within the selected core.
        # @note Register type indication is done per regster, when adding registers. This method just checks that field.
        def reg_wrapped_by_dcrsr?(reg)
          # If reg isn't an Origen register, convert it to one.
          r = reg.is_a?(Origen::Registers::Reg) ? reg : self.reg(reg)

          # The register type is a custom field stored in the registers metadata.
          r.meta[:general_purpose_register] || r.meta[:special_purpose_register] || r.meta[:floating_point_register]
        end
      end
    end
  end
end
