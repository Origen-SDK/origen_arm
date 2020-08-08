module OrigenARM
  module Cores
    module CortexA
      class CA35Controller < OrigenARM::Cores::BaseController

        def initialize_core(pc:, release_core: false, **options)
          halt_core!
          set_pc!(pc)
          
          if release_core
            release_core!
          end
        end
        
        def halt_core!
          ss 'Halt core - channel 0'
          reg(:trace_cti_lar).write!(0xC5AC_CE55)
          reg(:trace_cti_ctrl).write!(0x1)
          reg(:trace_cti_outen0).write!(0x1)
          reg(:trace_cti_apppulse).write!(0x1)
          tester.cycle(repeat: 10_000)

          ss 'Check that the core is halted'
          reg(:trace_dbg_edprsr).read!(0x10, mask: 0x0000_0010)

          ss 'Acknowledge'
          reg(:trace_cti_intack).write!(0x1)
          tester.cycle(repeat: 100)

          reg(:trace_dbg_lar).write!(0xC5AC_CE55)
          reg(:trace_dbg_oslar).write!(0xABCD_1234)
          tester.cycle(repeat: 100)
        end
        
        def release_core!
          ss 'Release core - channel 2'
          reg(:trace_cti_lar).write!(0xC5AC_CE55)
          reg(:trace_cti_ctrl).write!(0x1)
          reg(:trace_cti_outen1).write!(0x4)
          reg(:trace_cti_apppulse).write!(0x4)
          tester.cycle(repeat: 100)
          ss 'Check that the core has been released'
          reg(:trace_dbg_edprsr).read!(0x0, mask: 0x0000_0010)
        end
        
        def set_pc!(pc)
          ss 'Move the PC'
          reg(:trace_dbg_dtrtx).write!((pc >> 32) & 0xFFFF_FFFF)
          reg(:trace_dbg_dtrrx).write!(pc & 0xFFFF_FFFF)
          reg(:trace_dbg_editr).write!(0xD533_0401)
          tester.cycle(repeat: 100)
          reg(:trace_dbg_editr).write!(0xD51B_4521)
          tester.cycle(repeat: 100)
        end

      end
    end
  end
end

