# The information referenced in this file was taken from the readily-available
# online ARM documentation and is included here as a resource for developers.
# See http://infocenter.arm.com/help/index.jsp for the original source.
# This source can also be downloaded from https://developer.arm.com/ and selecting
# 'technical support' (login required).

module OrigenARM
  module Cores
    module CortexM
      class CM33
        module Registers
          AIRCR_READ_KEY = 0xFA05
          AIRCR_WRITE_KEY = 0x05FA
          DHCSR_DBGKEY = 0xA05F

          def instantiate_registers(options = {})
            add_reg(:aircr, 0xE000_ED0C, size: 32, description: 'Application Interrupt and Reset Control Register') do |r|
              r.bit 31..16, :vectkey, description: 'Vector key. Writes to the AIRCR must be accompanied by a write of the value 0x05FA to this field. Writes to the AIRCR fields that are not accompanied by this value are ignored for the purpose of dating any of the AIRCR values or initiating any AIRCR functionality.'
              r.bit 15, :endianness, description: 'Data endianness. Indicates how the PE interprets the memory system data endianness. 0 -> Little-endian, 1 -> Big-endian.'
              r.bit 14, :pris, description: 'Prioritize Secure exceptions. The value of this bit defines whether Secure exception priority boosting is enabled. 0 -> Priority ranges of Secure and Non-secure exceptions are identical, 1 -> Non-secure exceptions are de-prioritized.'
              r.bit 13, :bfhfnmins, description: 'BusFault, HardFault, and NMI Non-secure enable. The value of this bit defines whether BusFault and NMI exceptions are Non-secure, and whether exceptions target the Non-secure HardFault exception. 0 -> BusFault, HardFault, and NMI are Secure, 1 -> BusFault and NMI are Non-secure and exceptions can target Non-secure HardFault.'
              r.bit 12..11, :reserved
              r.bit 10..8, :prigroup, description: 'Priority grouping. The value of this field defines the exception priority binary point position for the selected Security state.'
              r.bit 7..4, :reserved
              r.bit 3, :sysresetreqs, description: 'System reset request Secure only. The value of this bit defines whether the SYSRESETREQ bit is functional for Non-secure use. 0 -> SYSRESETREQ functionality is available to both Security states, 1 -> SYSRESETREQ functionality is only available to Secure state.'
              r.bit 2, :sysresetreq, description: 'System reset request. This bit allows software or a debugger to request a system reset. 0 -> Do not request a system reset., 1 -> Request a system reset.'
              r.bit 1, :vectclractive, description: 'Clear active state. A debugger write of one to this bit when the PE is halted in Debug state. 0 -> Do nothing, 1 -> Clear active state (IPSR is cleared to zero, The active state for all Non-secure exceptions is cleared, If DHCSR.S_SDE==1, the active state for all Secure exceptions is cleared).'
              r.bit 0, :reserved
            end

            add_reg(:dhcsr, 0xE000_EDF0, size: 32, description: 'Debug Halting Control and Status Register') do |r|
              r.bit 31..16, :dbgkey, description: 'Debug key. A debugger must write 0xA05F to this field to enable write access to the remaining bits, otherwise the PE ignores the write access.'
              r.bit 15..6, :reserved
              r.bit 5, :c_snapstall, description:
                [
                  'Snap stall control.',
                  'Setting this bit to 1 allows a debugger to request an imprecise entry to Debug state. Writing 1 to this makes the state of the memory system UNPREDICTABLE. Therefore if a debugger writes 1 to this bit it must reset the system before leaving Debug state.', 'Allow imprecise entry to Debug state.',
                  'The effect of setting this bit to 1 is UNPREDICTABLE unless the DHCSR write also sets C_DEBUGEN and C_HALT to 1. This means that if the PE is not already in Debug state, it enters Debug state when the stalled instruction completes.',
                  'If the Security Extension is implemented, then writes to this bit are ignored when DHCSR.S_SDE == 0.',
                  'If DHCSR.C_DEBUGEN == 0 or HaltingDebugAllowed() == FALSE, the PE ignores this bit and behaves as if it is set to 0.',
                  'If the Main Extension is not implemented, this bit is RES0.',
                  '0 -> No action.',
                  '1 -> Allows imprecise entry to Debug state, for example by forcing any stalled load or store instruction to be abandoned.'
                ].join("\n")
              r.bit 4, :reserved
              r.bit 3, :c_maskints, description:
                [
                  'Mask interrupts control. When debug is enabled, the debugger can write to this bit to mask PendSV, SysTick and external configurable interrupts.',
                  'The effect of any single write to DHCSR that changes the value of this bit is UNPREDICTABLE unless one of:',
                  'Before the write, DHCSR.{S_HALT,C_HALT} are both set to 1 and the write also writes 1 to DHCSR.C_HALT.',
                  'Before the write, DHCSR.C_DEBUGEN == 0 or HaltingDebugAllowed() == FALSE, and the write writes 0 to DHCSR.C_MASKINTS. This means that a single write to DHCSR must not clear DHCSR.C_HALT to 0 and change the value of the C_MASKINTS bit.',
                  'If the Security Extension is implemented and DHCSR.S_SDE == 0, this bit does not affect
                  interrupts targeting Secure state.',
                  'If DHCSR.C_DEBUGEN == 0 or HaltingDebugAllowed() == FALSE, the PE ignores this bit and behaves as if it is set to 0.',
                  'If DHCSR.C_DEBUGEN == 0 this but reads as an UNKNOWN value.',
                  'This bit resets to an UNKNOWN value on a Cold reset.',
                  '0 -> Do not mask.',
                  '1 -> Mask PendSV, SysTick and external configurable interrupts.'
                ].join("\n")
              r.bit 2, :c_step, reset: 0,  description:
                [
                  'Step control. Enable single instruction step.',
                  'The effect of a single write to DHCSR that changes the value of this bit is UNPREDICTABLE unless one of:',
                  'Before the write, DHCSR.{S_HALT,C_HALT} are both set to 1.',
                  'Before the write, DHCSR.C_DEBUGEN == 0 or HaltingDebugAllowed() == FALSE, and the write writes 0 to DHCSR.C_STEP.',
                  'The PE ignores this bit and behaves as if it set to 0 if any of:',
                  'DHCSR.C_DEBUGEN == 0 or HaltingDebugAllowed() == FALSE.',
                  'The Security Extension is implemented, DHCSR.S_SDE == 0 and the PE is in Secure state.',
                  'If DHCSR.C_DEBUGEN == 0 this bit reads as an UNKNOWN',
                  '0 -> No effect.',
                  '1 -> Single step enabled.'
                ].join("\n")
              r.bit 1, :c_halt, reset: 0, description:
                [
                  'Halt control. PE to enter Debug state halt request.',
                  'The PE sets C_HALT to 1 when a debug event pends an entry to Debug state.',
                  'The PE ignores this bit and behaves as if it is set to 0 if any of:',
                  'DHCSR.C_DEBUGEN == 0 or HaltingDebugAllowed() == FALSE.',
                  'The Security Extension is implemented, DHCSR.S_SDE == 0 and the PE is in Secure state.',
                  'If DHCSR.C_DEBUGEN == 0 this bit reads as an UNKNOWN value.',
                  'This bit resets to zero on a Warm reset.',
                  '0 -> Causes the PE to leave Debug state, if in Debug state.',
                  '1 -> Halt the PE.'
                ].join("\n")
              r.bit 0, :c_debugen, reset: 0,  description:
                [
                  'Debug enable control. Enable Halting debug.',
                  'The possible values of this bit are:',
                  'If a debugger writes to DHCSR to change the value of this bit from 0 to 1, it must also write 0 to the C_MASKINTS bit, otherwise behavior is UNPREDICTABLE.',
                  'If this bit is set to 0:',
                  'The PE behaves as if DHCSR.{C_MASKINTS, C_STEP, C_HALT} are all set to 0.',
                  'DHCSR.{S_RESTART_ST, C_MASKINTS, C_STEP, C_HALT} are UNKNOWN on reads of DHCSR.',
                  'This bit is read/write to the debugger. Writes from software are ignored.',
                  'This bit resets to zero on a Cold reset.',
                  '0 -> Disabled.',
                  '1 -> Enabled.'
                ].join("\n")
            end

            add_reg(:dcrsr, 0xE000_EDF4, size: 32, description: 'Debug Core Register Select Register') do |r|
              r.bit 31..17, :reserved
              r.bit 16, :regwnr, description:
                [
                  'Register write/not-read. Specifies the access type for the transfer.',
                  '0 -> Read.',
                  '1 -> Write.'
                ].join("\n")
              r.bit 15..7, :reserved
              # Register definition from the reference manual:
              #     Register selector. Specifies the general-purpose register, special-purpose register, or Floating-point
              #     Extension register to transfer.
              #     The possible values of this field are:
              #     0b0000000-0b0001100
              #     General-purpose registers R0-R12.
              #     0b0001101 Current stack pointer, SP.
              #     0b0001110 LR.
              #     0b0001111 DebugReturnAddress.
              #     0b0010000 XPSR.
              #     0b0010001 Current state main stack pointer, SP_main.
              #     0b0010010 Current state process stack pointer, SP_process.
              #     0b0010100 Current state {CONTROL[7:0],FAULTMASK[7:0],BASEPRI[7:0],PRIMASK[7:0]}.
              #     If the Main Extension is not implemented, bits [23:8] of the transfer value are RES0.
              #     0b0011000 Non-secure main stack pointer, MSP_NS.
              #     If the Security Extension is not implemented, this value is reserved.
              #     0b0011001 Non-secure process stack pointer, PSP_NS.
              #     If the Security Extension is not implemented, this value is reserved.
              #     0b0011010 Secure main stack pointer, MSP_S. Accessible only when DHCSR.S_SDE == 1.
              #     If the Security Extension is not implemented, this value is reserved.
              #     0b0011011 Secure process stack pointer, PSP_S. Accessible only when DHCSR.S_SDE == 1.
              #     If the Security Extension is not implemented, this value is reserved.
              #     0b0011100 Secure main stack limit, MSPLIM_S. Accessible only when DHCSR.S_SDE ==
              #     0b0011101 Secure process stack limit, PSPLIM_S. Accessible only when DHCSR.S_SDE == 1.
              #     If the Security Extension is not implemented, this value is reserved.
              #     0b0011110 Non-secure main stack limit, MSPLIM_NS.
              #     If the Main Extension is not implemented, this value is reserved.
              #     0b0011111 Non-secure process stack limit, PSPLIM_NS.
              #     If the Main Extension is not implemented, this value is reserved.
              #     0b0100001 FPSCR.
              #     If the Floating-point Extension is not implemented, this value is reserved.
              #     0b0100010 {CONTROL_S[7:0],FAULTMASK_S[7:0],BASEPRI_S[7:0],PRIMASK_S[7:0]}.
              #     Accessible only when DHCSR.S_SDE == 1.
              #     If the Main Extension is not implemented, bits [23:8] of the transfer value are RES0. If
              #     the Security Extension is not implemented, this value is reserved.
              #     0b0100011
              #     {CONTROL_NS[7:0],FAULTMASK_NS[7:0],BASEPRI_NS[7:0],PRIMASK_NS[7:
              #     0]}.
              #     If the Main Extension is not implemented, bits [23:8] of the transfer value are RES0. If
              #     the Security Extension is not implemented, this value is reserved.
              #     0b1000000-0b1011111
              #     FP registers, S0-S31.
              #     If the Floating-point Extension is not implemented, these values are reserved.
              #     All other values are reserved.
              #     If the Floating-point and Security Extensions are implemented, then FPSCR and S0-S31 are not
              #     accessible from Non-secure state if DHCSR.S_SDE == 0 and either:
              #       FPCCR indicates the registers contain values from Secure state.
              #       NSACR prevents Non-secure access to the registers.
              #     Registers that are not accessible are RAZ/WI.
              #     If this field is written with a reserved value, the PE might behave as if a defined value was written,
              #     or ignore the value written, and the value of DCRDR becomes UNKNOWN.
              r.bit 6..0, :reg_sel, description:
                [
                  'Register selector.',
                  'Specifies the general-purpose register, special-purpose register, or Floating-point Extension register to transfer.'
                ].join("\n")
            end

            add_reg(:dcrdr, 0xE000_EDF8, size: 32, description: 'Debug Core Register Data Register') do |r|
              r.bits 31..0, :dbgtmp, description:
                [
                  'Data temporary buffer. Provides debug access for reading and writing the general-purpose registers, ' \
                  'special-purpose registers, and Floating-point Extension registers.',

                  'The value of this register is UNKNOWN if the PE is in Debug state, the debugger has written to ' \
                  'DCRSR since entering Debug state and DHCSR.S_REGRDY is set to 0. The value of this register ' \
                  'is UNKNOWN if the Main Extension is not implemented and the PE is in Non-debug state.',

                  'This field resets to an UNKNOWN value on a Warm reset.',
                  'Any written contents will be overwritten on a successful core-register read attempt.'
                ].join("\n")
            end

            add_reg(:demcr, 0xE000_EDFC, size: 32, description: 'Debug Exception and Monitor Control Register') do |r|
              r.bits 31..25, :reserved
              r.bits 24, :trcena, description:
                [
                  'Trace enable. Global enable for all DWT and ITM features.',

                  'If the DWT and ITM units are not implemented, this bit is RES0. See the descriptions of DWT and ' \
                  'ITM for details of which features this bit controls.',

                  'Setting this bit to 0 might not stop all events. To ensure that all events are stopped, software must ' \
                  'set all DWT and ITM feature enable bits to 0, and ensure that all trace generated by the DWT and ' \
                  'ITM has been flushed, before setting this bit to 0.',

                  'It is IMPLEMENTATION DEFINED whether this bit affects how the system processes trace. ' \
                  'Arm recommends that this bit is set to 1 when using an ETM even if any implemented DWT and ' \
                  'ITM are not being used.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> DWT and ITM features disabled.',
                  '1 -> DWT and ITM features enabled.'
                ].join("\n")
              r.bits 23..21, :reserved
              r.bits 20, :sdme, description:
                [
                  'Secure DebugMonitor enable. Indicates whether the DebugMonitor targets the Secure or the ' \
                  'Non-secure state and whether debug events are allowed in Secure state.',

                  'When DebugMonitor exception is not pending or active, this bit reflects the value of ' \
                  'SecureDebugMonitorAllowed(), otherwise, the previous value is retained.',

                  'This bit is read-only.',

                  'If the Security Extension is not implemented, this bit is RES0. ' \
                  'If the Main Extension is not implemented, this bit is RES0.',

                  '0 -> Debug events prohibited in Secure state and the DebugMonitor exception targets Non-secure state.',
                  '1 -> Debug events allowed in Secure state and the DebugMonitor exception targets Secure state.'
                ].join("\n")
              r.bits 19, :mon_req, description:
                [
                  'Monitor request. DebugMonitor semaphore bit.',

                  'The PE does not use this bit. The monitor software defines the meaning and use of this bit.',

                  'If the Main Extension is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Warm reset.'
                ].join("\n")
              r.bits 18, :mon_step, description:
                [
                  'Monitor step. Enable DebugMonitor exception stepping.',

                  'The effect of changing this bit at an execution priority that is lower than the priority of the ' \
                  'DebugMonitor exception is UNPREDICTABLE.',

                  'If the Main Extension is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Warm reset.',

                  '0 -> Stepping disabled.',
                  '1 -> Stepping enabled.'
                ].join("\n")
              r.bits 17, :mon_pend, description:
                [
                  'Monitor pend. Sets or clears the pending state of the DebugMonitor exception.',

                  'When the DebugMonitor exception is pending it becomes active subject to the exception priority ' \
                  'rules. The effect of setting this bit to 1 is not affected by the value of the MON_EN bit. This means ' \
                  'that software or a debugger can set MON_PEND to 1 and pend a DebugMonitor exception, even ' \
                  'when MON_EN is set to 0.',

                  'If the Main Extension is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Warm reset.',

                  '0 -> Clear the status of the DebugMonitor exception to not pending.',
                  '1 -> Set the status of the DebugMonitor exception to pending.'
                ].join("\n")
              r.bits 16, :mon_en, description:
                [
                  'Monitor enable. Enable the DebugMonitor exception.',

                  'If a debug event halts the PE, the PE ignores the value of this bit.',
                  'If DEMCR.SDME is one this bit is RAZ/WI from Non-secure state',

                  'If the Main Extension is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Warm reset.',

                  '0 -> DebugMonitor exception disabled.',
                  '1 -> DebugMonitor exception enabled.'
                ].join("\n")
              r.bits 15..12, :reserved
              r.bits 11, :vc_sferr, description:
                [
                  'Vector Catch SecureFault. SecureFault exception Halting debug vector catch enable.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or DHCSR.S_SDE == 0.',

                  'If the Security Extension is not implemented, this bit is RES0.',
                  'If the Main Extension is not implemented, this bit is RES0.',
                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on SecureFault disabled.',
                  '1 -> Halting debug trap on SecureFault enabled.'
                ].join("\n")
              r.bits 10, :vc_harderr, description:
                [
                  'Vector Catch HardFault errors. HardFault exception Halting debug vector catch enable.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or the Security Extension is implemented, DHCSR.S_SDE == 0 and the exception targets ' \
                  'Secure state.',

                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on HardFault disabled.',
                  '1 -> Halting debug trap on HardFault enabled.'
                ].join("\n")
              r.bits 9, :vc_interr, description:
                [
                  'Vector Catch interrupt errors. Enable Halting debug vector catch for faults arising in lazy state ' \
                  'preservation and during exception entry or return.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or the Security Extension is implemented, DHCSR.S_SDE == 0 and the exception targets Secure state.',

                  'If the Main Extension is not implemented, this bit is RES0.',
                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on faults disabled.',
                  '1 -> Halting debug trap on faults enabled.'
                ].join("\n")
              r.bits 8, :vc_buserr, description:
                [
                  'Vector Catch BusFault errors. BusFault exception Halting debug vector catch enable.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or the Security Extension is implemented, DHCSR.S_SDE == 0 and the exception targets ' \
                  'Secure state.',

                  'If the Main Extension is not implemented, this bit is RES0.',
                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on BusFault disabled.',
                  '1 -> Halting debug trap on BusFault enabled.'
                ].join("\n")
              r.bits 7, :vc_staterr, description:
                [
                  'Vector Catch state errors. Enable Halting debug trap on a UsageFault exception caused by a state ' \
                  'information error, for example an Undefined Instruction exception.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or the Security Extension is implemented, DHCSR.S_SDE == 0 and the exception targets ' \
                  'Secure state.',

                  'If the Main Extension is not implemented, this bit is RES0.',
                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on UsageFault caused by state information error disabled.',
                  '1 -> Halting debug trap on UsageFault caused by state information error enabled.'
                ].join("\n")
              r.bits 6, :vc_chkerr, description:
                [
                  'Vector Catch check errors. Enable Halting debug trap on a UsageFault exception caused by a ' \
                  'checking error, for example an alignment check error.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or the Security Extension is implemented, DHCSR.S_SDE == 0 and the exception targets ' \
                  'Secure state.',

                  'If the Main Extension is not implemented, this bit is RES0.',
                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on UsageFault caused by checking error disabled.',
                  '1 -> Halting debug trap on UsageFault caused by checking error enabled.'
                ].join("\n")
              r.bits 5, :vc_nocperr, description:
                [
                  'Vector Catch NOCP errors. Enable Halting debug trap on a UsageFault caused by an access to a coprocessor.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or the Security Extension is implemented, DHCSR.S_SDE == 0 and the exception targets ' \
                  'Secure state.',

                  'If the Main Extension is not implemented, this bit is RES0.',
                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on UsageFault caused by access to a coprocessor disabled.',
                  '1 -> Halting debug trap on UsageFault caused by access to a coprocessor enabled.'
                ].join("\n")
              r.bits 4, :vc_mmerr, description:
                [
                  'Vector Catch MemManage errors. Enable Halting debug trap on a MemManage exception.',

                  'The PE ignores the value of this bit if DHCSR.C_DEBUGEN == 0, HaltingDebugAllowed() == ' \
                  'FALSE, or the Security Extension is implemented, DHCSR.S_SDE == 0 and the exception targets ' \
                  'Secure state.',

                  'If the Main Extension is not implemented, this bit is RES0.',
                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on MemManage disabled.',
                  '1 -> Halting debug trap on MemManage enabled.'
                ].join("\n")
              r.bits 3..1, :reserved
              r.bits 0, :rv_corereset, description:
                [
                  'Vector Catch Core reset. Enable Reset Vector Catch. This causes a Warm reset to halt a running system.',

                  'If DHCSR.C_DEBUGEN == 0 or HaltingDebugAllowed() == FALSE, the PE ignores the value of ' \
                  'this bit. Otherwise, when this bit is set to 1 a Warm reset will pend a Vector Catch debug event. The ' \
                  'debug event is pended even the PE resets into Secure state and DHCSR.S_SDE == 0.',

                  'If Halting debug is not implemented, this bit is RES0.',

                  'This bit resets to zero on a Cold reset.',

                  '0 -> Halting debug trap on reset disabled.',
                  '1 -> Halting debug trap on reset enabled.'
                ].join("\n")
            end
          end
        end
      end
    end
  end
end
