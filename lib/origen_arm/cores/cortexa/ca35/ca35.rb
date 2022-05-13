module OrigenARM
  module Cores
    module CortexA
      class CA35 < OrigenARM::Cores::Base
        TRACE_DBG_EDPRSR_OFFSET = 0x314
        TRACE_LAR_OFFSET = 0xFB0
        TRACE_OSLAR_OFFSET = 0x300
        TRACE_CTI_CTRL_OFFSET = 0x000
        TRACE_CTI_OUTEN0_OFFSET = 0x0A0
        TRACE_CTI_APPPULSE_OFFSET = 0x01C
        TRACE_CTI_INTACK_OFFSET = 0x010
        TRACE_DBG_EDITR_OFFSET = 0x84
        TRACE_DBG_EDSCR_OFFSET = 0x88
        TRACE_DBG_DTRTX_OFFSET = 0x8C
        TRACE_DBG_DTRRX_OFFSET = 0x80
        CTI_BASE = 0x0042_0000
        DBG_BASE = 0x0041_0000

        attr_reader :core_num, :reg_base_core_num_offset
        attr_reader :halt_channel, :release_channel

        def initialize(options = {})
          @core_num = options[:core_num] || 0
          @reg_base_core_num_offset = options[:reg_base_core_num_offset] || (0x10_0000 * core_num)
          @halt_channel = options[:halt_channel] || (1 << core_num)
          @release_channel = options[:release_channel] || (4 << core_num)
          super
          instantiate_registers(options)
        end

        def instantiate_registers(options)
          add_reg(:trace_dbg_edprsr, DBG_BASE + reg_base_core_num_offset + TRACE_DBG_EDPRSR_OFFSET, size: 32)
          add_reg(:trace_dbg_editr, DBG_BASE + reg_base_core_num_offset + TRACE_DBG_EDITR_OFFSET, size: 32)
          add_reg(:trace_dbg_edscr, DBG_BASE + reg_base_core_num_offset + TRACE_DBG_EDSCR_OFFSET, size: 32)
          add_reg(:trace_dbg_dtrtx, DBG_BASE + reg_base_core_num_offset + TRACE_DBG_DTRTX_OFFSET, size: 32)
          add_reg(:trace_dbg_dtrrx, DBG_BASE + reg_base_core_num_offset + TRACE_DBG_DTRRX_OFFSET, size: 32)
          add_reg(:trace_dbg_lar, DBG_BASE + reg_base_core_num_offset + TRACE_LAR_OFFSET, size: 32)
          add_reg(:trace_dbg_oslar, DBG_BASE + reg_base_core_num_offset + TRACE_OSLAR_OFFSET, size: 32)
          add_reg(:trace_cti_ctrl, CTI_BASE + reg_base_core_num_offset + TRACE_CTI_CTRL_OFFSET, size: 32)
          add_reg(:trace_cti_outen0, CTI_BASE + reg_base_core_num_offset + TRACE_CTI_OUTEN0_OFFSET, size: 32)
          add_reg(:trace_cti_outen1, CTI_BASE + reg_base_core_num_offset + TRACE_CTI_OUTEN0_OFFSET + 0x4, size: 32)
          add_reg(:trace_cti_apppulse, CTI_BASE + reg_base_core_num_offset + TRACE_CTI_APPPULSE_OFFSET, size: 32)
          add_reg(:trace_cti_intack, CTI_BASE + reg_base_core_num_offset + TRACE_CTI_INTACK_OFFSET, size: 32)
          add_reg(:trace_cti_lar, CTI_BASE + reg_base_core_num_offset + TRACE_LAR_OFFSET, size: 32)
        end
      end
    end
  end
end
