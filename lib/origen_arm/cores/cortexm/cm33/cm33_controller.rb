module OrigenARM
  module Cores
    module CortexM
      class CM33Controller < OrigenARM::Cores::CortexM::BaseController
        def initialize(options = {})
          super
        end

        # Initializes the core, specifically geared towards LRE setup.
        # @param pc [Fixnum] The absolute address to load into the program counter.
        # @param sp [Fixnum] The absolute address to load into the current stack pointer.
        # @param release_core [TrueClass, FalseClass] The core will need to be held in order to initialize. However, this parameter
        #   can indicate whether or not the core should be released following the setup.
        # @param sp_lower_limit [Fixnum] Sets stack pointer's lower limit.
        # @param sp_upper_limit [Fixnum] Sets stack pointer's upper limit.
        # @todo Implement lower and upper stack pointer limit setting.
        def initialize_core(pc:, sp:, release_core: false, sp_lower_limit: nil, sp_upper_limit: nil, release_cpu_wait: true)
          enter_debug_mode(release_cpu_wait: release_cpu_wait)

          # clear_state
          # clear_state

          # ss 'Disable the MPU and the SAU'
          # mem(0xE000_ED94).write!(0x0, force_arm_debug: true)
          # mem(0xE000_EDD0).write!(0x0, force_arm_debug: true)

          # ss 'Move the stack pointer limits'
          # mem(0xE000_EDF8).write!(0x1400_6800, force_arm_debug: true)
          # mem(0xE000_EDF4).write!(0x0001_0000 + 0x1C, force_arm_debug: true)

          set_sp(sp)
          set_pc(pc)

          # set_stack_limits(sp_lower_limit, sp_upper_limit) if (sp_lower_limit || sp_upper_limit)
          exit_debug_mode(release_core: release_core)

          # reg(:aircr).bits(:vectkey).write(CM33::Registers::AIRCR_WRITE_KEY)
          # reg(:aircr).bits(:sysresetreq).write(1)
          # reg(:aircr).write!
        end
        alias_method :initialize_for_lre, :initialize_core

        # Enters the core's debug mode.
        # @param halt_core [true, false] Indicates whether the core should be held when entering debug mode.
        #   Some functionality may not work correctly if the core is not halted,
        #   but a halted core is not a requirement for debug mode.
        def enter_debug_mode(halt_core: true, release_cpu_wait: true)
          pp('Entering Debug Mode...') do
            reg(:dhcsr).bits(:dbgkey).write(OrigenARM::Cores::CortexM::CM33::Registers::DHCSR_DBGKEY)
            reg(:dhcsr).bits(:c_debugen).write(1)
            reg(:dhcsr).write!

            enter_debug_mode_delay!

            if halt_core
              reg(:dhcsr).bits(:dbgkey).write(OrigenARM::Cores::CortexM::CM33::Registers::DHCSR_DBGKEY)
              reg(:dhcsr).bits(:c_debugen).write(1)
              reg(:dhcsr).bits(:c_halt).write(1)
              reg(:dhcsr).write!
              enter_debug_mode_delay!
            end

            if release_cpu_wait
              if cpu_wait_release
                cpu_wait_release.call(self)
              end
            end
          end
        end

        # Exits the core's debug mode.
        # @param release_core [true, false] Indicates whether the core should be held upon exiting debug mode.
        def exit_debug_mode(release_core: true)
          pp('Exiting Debug Mode...') do
            reg(:dhcsr).bits(:dbgkey).write(OrigenARM::Cores::CortexM::CM33::Registers::DHCSR_DBGKEY)
            reg(:dhcsr).bits(:c_halt).write(0) if release_core
            reg(:dhcsr).bits(:c_debugen).write(0)
            reg(:dhcsr).write!

            cc 'Delay for the core to exit debug mode'
            exit_debug_mode_delay!
          end
        end

        # Sets the current stack pointer.
        # @param sp [Fixnum] The new stack pointer.
        # @note This sets the <b>current</b> stack pointer. The stack pointer in question
        #   depends on the core's/device's mode and security settings.
        # @note This requires the core to be in debug mode, otherwise a bus error will occur.
        def set_sp(sp)
          pp('Patch the Stack Pointer') do
            reg(:sp).write!(sp)
          end
        end

        # Sets the program counter by writing the <code>debug_return_address</code> register.
        # The <code>debug_return_address</code> will be loaded into the PC following
        # debug mode exit, effectively moving the PC.
        # @param pc [Fixnum] The new program counter (debug return address).
        # @note This requires the core to be in debug mode, otherwise a bus error will occur.
        # @note This method will also force <code>Thumb</code> mode.
        def set_pc(pc)
          pp('Patch the Program Counter') do
            # Force the thumb bit. Nothing will work otherwise as CM33 only support THUMB
            reg(:xpsr).bits(:t).write(1)
            reg(:xpsr).write!

            # Write the debug return address with the new PC
            # Add 1 to indicate thumb mode
            reg(:debug_return_address).write!(pc + 1)
          end
        end

        # def clear_state
        #  pp("Clear the core's current state") do
        #    reg(:aircr).bits(:vectkey).write(CM33::Registers::AIRCR_WRITE_KEY)
        #    reg(:aircr).bits(:sysresetreq).write(1)
        #    #reg(:aircr).bits(:vectclractive).write(1)
        #    reg(:aircr).write!
        #
        #    tester.cycle(repeat: 1000)
        #  end
        # end

        # def set_stack_limits(lower_limit, upper_limits, stack: :msp, **options)
        # end
      end
    end
  end
end
