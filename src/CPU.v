`timescale 1ns / 1ps

module CPU (
    input clk,
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,      // Instruction address (The same as current PC)
    input [31:0] im_dout,       // Instruction data (Current instruction)
    output [31:0] mem_addr,     // Memory read/write address
    output mem_we,              // Memory writing enable
    output [2:0] mem_type,     // Memory read/write type
    output [31:0] mem_din,      // Data ready to write to memory
    input [31:0] mem_dout,	    // Data read from memory

    // Debug BUS with PDU
    output [31:0] current_pc, 	        // Current_pc, pc_out
    output [31:0] next_pc,              // Next_pc, pc_in
    input [31:0] cpu_check_addr,	    // Check current datapath state (code)
    output [31:0] cpu_check_data    // Current datapath state data
);
    // [Internal]
    wire[31:0] inst_raw;
    wire[31:0] dm_dout;

    // [IF] pc
    wire[31:0] pc_cur_if;

    // [IF] inst_flush
    wire[31:0] inst_if;

    // [IF] adder1
    wire[31:0] pc_add4_if;

    // [IF/ID] seg_reg_if_id
    wire[31:0] pc_cur_id;
    wire[31:0] inst_id;
    wire[4:0] rf_ra0_id,rf_ra1_id;
    // wire rf_re0_id,rf_re1_id;
    // wire[31:0] rf_rd0_raw_id,rf_rd1_raw_id;
    // wire[31:0] rf_rd0_id,rf_rd1_id;
    wire[4:0] rf_wa_id;
    // wire[1:0] rf_wd_sel_id;
    // wire rf_we_id;
    // wire[2:0] imm_type_id;
    // wire[31:0] imm_id;
    // wire alu_src1_sel_id,alu_src2_sel_id;
    // wire[31:0] alu_src1_id,alu_src2_id;
    // wire[3:0] alu_func_id;
    // wire[31:0] alu_ans_id;
    wire[31:0] pc_add4_id;
    // wire[31:0] pc_br_id;
    // wire[31:0] pc_jal_id;
    // wire[31:0] pc_jalr_id;
    // wire jal_id,jalr_id;
    // wire[2:0] br_type_id;
    // wire br_id;
    // wire[1:0] pc_sel_id;
    // wire[31:0] pc_next_id;
    // wire[31:0] dm_addr_id;
    // wire[31:0] dm_din_id,dm_dout_id;
    // wire dm_we_id;
    // wire[2:0] dm_type_id;

    // [ID] ctrl
    wire rf_re0_id,rf_re1_id,rf_we_id;
    wire[1:0] rf_wd_sel_id;
    wire[2:0] imm_type_id;
    wire jal_id,jalr_id;
    wire[2:0] br_type_id;
    wire alu_src1_sel_id,alu_src2_sel_id;
    wire[3:0] alu_func_id;
    wire dm_we_id;
    wire[2:0] dm_type_id;

    // [ID] rf
    wire[31:0] rf_rd0_raw_id,rf_rd1_raw_id,rf_rd_dbg_id;

    // [ID] immediate
    wire[31:0] imm_id;

    // [ID] adder2
    wire[31:0] pc_jal_id;

    // [ID/EX] seg_reg_id_ex
    wire[31:0] pc_cur_ex;
    wire[31:0] inst_ex;
    wire[4:0] rf_ra0_ex,rf_ra1_ex;
    wire rf_re0_ex,rf_re1_ex;
    wire[31:0] rf_rd0_raw_ex,rf_rd1_raw_ex;
    // wire[31:0] rf_rd0_ex,rf_rd1_ex;
    wire[4:0] rf_wa_ex;
    wire[1:0] rf_wd_sel_ex;
    wire rf_we_ex;
    wire[2:0] imm_type_ex;
    wire[31:0] imm_ex;
    wire alu_src1_sel_ex,alu_src2_sel_ex;
    // wire[31:0] alu_src1_ex,alu_src2_ex;
    wire[3:0] alu_func_ex;
    // wire[31:0] alu_ans_ex;
    wire[31:0] pc_add4_ex;
    // wire[31:0] pc_br_ex;
    wire[31:0] pc_jal_ex;
    // wire[31:0] pc_jalr_ex;
    wire jal_ex,jalr_ex;
    wire[2:0] br_type_ex;
    // wire br_ex;
    // wire[1:0] pc_sel_ex;
    // wire[31:0] pc_next_ex;
    // wire[31:0] dm_addr_ex;
    // wire[31:0] dm_din_ex,dm_dout_ex;
    wire dm_we_ex;
    wire[2:0] dm_type_ex;

    // [EX] rf_rd0_fwd
    wire[31:0] rf_rd0_ex;

    // [EX] rf_rd1_fwd
    wire[31:0] rf_rd1_ex;

    // [EX] alu_sel1
    wire[31:0] alu_src1_ex;

    // [EX] alu_sel2
    wire[31:0] alu_src2_ex;

    // [EX] alu
    wire[31:0] alu_ans_ex;

    // [EX] branch
    wire br_ex;

    // [EX] pc_sel_gen
    wire[1:0] pc_sel_ex;

    // [EX] ander
    wire[31:0] pc_jalr_ex;

    // [EX] npc_sel
    wire[31:0] pc_next;

    // [EX/MEM] seg_reg_ex_mem
    wire[31:0] pc_cur_mem;
    wire[31:0] inst_mem;
    wire[4:0] rf_ra0_mem,rf_ra1_mem;
    wire rf_re0_mem,rf_re1_mem;
    wire[31:0] rf_rd0_raw_mem,rf_rd1_raw_mem;
    wire[31:0] rf_rd0_mem,rf_rd1_mem;
    wire[4:0] rf_wa_mem;
    wire[1:0] rf_wd_sel_mem;
    wire rf_we_mem;
    wire[2:0] imm_type_mem;
    wire[31:0] imm_mem;
    wire alu_src1_sel_mem,alu_src2_sel_mem;
    wire[31:0] alu_src1_mem,alu_src2_mem;
    wire[3:0] alu_func_mem;
    wire[31:0] alu_ans_mem;
    wire[31:0] pc_add4_mem;
    wire[31:0] pc_br_mem;
    wire[31:0] pc_jal_mem;
    wire[31:0] pc_jalr_mem;
    wire jal_mem,jalr_mem;
    wire[2:0] br_type_mem;
    wire br_mem;
    wire[1:0] pc_sel_mem;
    wire[31:0] pc_next_mem;
    wire[31:0] dm_addr_mem;
    wire[31:0] dm_din_mem/*,dm_dout_mem*/;
    wire dm_we_mem;
    wire[2:0] dm_type_mem;

    // [MEM/WB] seg_reg_mem_wb
    wire[31:0] pc_cur_wb;
    wire[31:0] inst_wb;
    wire[4:0] rf_ra0_wb,rf_ra1_wb;
    wire rf_re0_wb,rf_re1_wb;
    wire[31:0] rf_rd0_raw_wb,rf_rd1_raw_wb;
    wire[31:0] rf_rd0_wb,rf_rd1_wb;
    wire[4:0] rf_wa_wb;
    wire[1:0] rf_wd_sel_wb;
    wire rf_we_wb;
    wire[2:0] imm_type_wb;
    wire[31:0] imm_wb;
    wire alu_src1_sel_wb,alu_src2_sel_wb;
    wire[31:0] alu_src1_wb,alu_src2_wb;
    wire[3:0] alu_func_wb;
    wire[31:0] alu_ans_wb;
    wire[31:0] pc_add4_wb;
    wire[31:0] pc_br_wb;
    wire[31:0] pc_jal_wb;
    wire[31:0] pc_jalr_wb;
    wire jal_wb,jalr_wb;
    wire[2:0] br_type_wb;
    wire br_wb;
    wire[1:0] pc_sel_wb;
    wire[31:0] pc_next_wb;
    wire[31:0] dm_addr_wb;
    wire[31:0] dm_din_wb,dm_dout_wb;
    wire dm_we_wb;
    wire[2:0] dm_type_wb;

    // [WB] reg_write_sel
    wire[31:0] rf_wd_wb;

    // [HZD] hazard
    wire rf_rd0_fe,rf_rd1_fe;
    wire[31:0] rf_rd0_fd,rf_rd1_fd;
    wire stall_if,stall_id,stall_ex;
    wire flush_if,flush_id,flush_ex,flush_mem;

    // [DBG] check_data_sel_if
    wire[31:0] check_data_if;

    // [DBG] check_data_sel_id
    wire[31:0] check_data_id;

    // [DBG] check_data_sel_ex
    wire[31:0] check_data_ex;

    // [DBG] check_data_sel_mem
    wire[31:0] check_data_mem;

    // [DBG] check_data_sel_wb
    wire[31:0] check_data_wb;

    // [DBG] check_data_sel_hzd
    wire[31:0] check_data_hzd;

    // [DBG] check_data_seg_sel
    wire[31:0] check_data;

    // [DBG] cpu_check_data_sel
    // wire[31:0] cpu_check_data;

    assign inst_raw = im_dout;
    assign dm_dout = mem_dout;

    PC pc(
        .clk(clk),
        .rst(rst),
        .stall(stall_if),
        .pc_next(pc_next),
        .pc_cur(pc_cur_if)
    );
    MUX1 inst_flush(
        .sel(flush_if),
        .src0(inst_raw),
        .src1(32'h00000033),
        .res(inst_if)
    );
    ADD adder1(
        .lhs(32'h4),
        .rhs(pc_cur_if),
        .res(pc_add4_if)
    );
    SEG_REG seg_reg_if_id(
        .clk(clk),
        .flush(flush_id),
        .stall(stall_id),
        .pc_cur_in(pc_cur_if),
        .inst_in(inst_if),
        .rf_ra0_in(inst_if[19:15]),
        .rf_ra1_in(inst_if[24:20]),
        .rf_re0_in(0),
        .rf_re1_in(0),
        .rf_rd0_raw_in(0),
        .rf_rd1_raw_in(0),
        .rf_rd0_in(0),
        .rf_rd1_in(0),
        .rf_wa_in(inst_if[11:7]),
        .rf_wd_sel_in(0),
        .rf_we_in(0),
        .imm_type_in(0),
        .imm_in(0),
        .alu_src1_sel_in(0),
        .alu_src2_sel_in(0),
        .alu_src1_in(0),
        .alu_src2_in(0),
        .alu_func_in(0),
        .alu_ans_in(0),
        .pc_add4_in(pc_add4_if),
        .pc_br_in(0),
        .pc_jal_in(0),
        .pc_jalr_in(0),
        .jal_in(0),
        .jalr_in(0),
        .br_type_in(0),
        .br_in(0),
        .pc_sel_in(0),
        .pc_next_in(0),
        .dm_addr_in(0),
        .dm_din_in(0),
        .dm_dout_in(0),
        .dm_we_in(0),
        .dm_type_in(0),
        .pc_cur_out(pc_cur_id),
        .inst_out(inst_id),
        .rf_ra0_out(rf_ra0_id),
        .rf_ra1_out(rf_ra1_id),
        // .rf_re0_out(),
        // .rf_re1_out(),
        // .rf_rd0_raw_out(),
        // .rf_rd1_raw_out(),
        // .rf_rd0_out(),
        // .rf_rd1_out(),
        .rf_wa_out(rf_wa_id),
        // .rf_wd_sel_out(),
        // .rf_we_out(),
        // .imm_type_out(),
        // .imm_out(),
        // .alu_src1_sel_out(),
        // .alu_src2_sel_out(),
        // .alu_src1_out(),
        // .alu_src2_out(),
        // .alu_func_out(),
        // .alu_ans_out(),
        .pc_add4_out(pc_add4_id)
        // .pc_br_out(),
        // .pc_jal_out(),
        // .pc_jalr_out(),
        // .jal_out(),
        // .jalr_out(),
        // .br_type_out(),
        // .br_out(),
        // .pc_sel_out(),
        // .pc_next_out(),
        // .dm_addr_out(),
        // .dm_din_out(),
        // .dm_dout_out(),
        // .dm_we_out(),
        // .dm_type_out()
    );
    CTRL ctrl(
        .inst(inst_id),
        .rf_re0(rf_re0_id),
        .rf_re1(rf_re1_id),
        .rf_we(rf_we_id),
        .rf_wd_sel(rf_wd_sel_id),
        .imm_type(imm_type_id),
        .jal(jal_id),
        .jalr(jalr_id),
        .br_type(br_type_id),
        .alu_src1_sel(alu_src1_sel_id),
        .alu_src2_sel(alu_src2_sel_id),
        .alu_func(alu_func_id),
        .mem_we(dm_we_id),
        .mem_type(dm_type_id)
    );
    RF rf(
        .clk(clk),
        .we(rf_we_wb),
        .ra0(rf_ra0_id),
        .ra1(rf_ra1_id),
        .wa(rf_wa_wb),
        .wd(rf_wd_wb),
        .ra_dbg(cpu_check_addr[4:0]),
        .rd0(rf_rd0_raw_id),
        .rd1(rf_rd1_raw_id),
        .rd_dbg(rf_rd_dbg_id)
    );
    Immediate immediate(
        .inst(inst_id),
        .type(imm_type_id),
        .imm(imm_id)
    );
    ADD adder2(
        .lhs(pc_cur_id),
        .rhs(imm_id),
        .res(pc_jal_id)
    );
    SEG_REG seg_reg_id_ex(
        .clk(clk),
        .flush(flush_ex),
        .stall(stall_ex),
        .pc_cur_in(pc_cur_id),
        .inst_in(inst_id),
        .rf_ra0_in(rf_ra0_id),
        .rf_ra1_in(rf_ra1_id),
        .rf_re0_in(rf_re0_id),
        .rf_re1_in(rf_re1_id),
        .rf_rd0_raw_in(rf_rd0_raw_id),
        .rf_rd1_raw_in(rf_rd1_raw_id),
        .rf_rd0_in(0),
        .rf_rd1_in(0),
        .rf_wa_in(rf_wa_id),
        .rf_wd_sel_in(rf_wd_sel_id),
        .rf_we_in(rf_we_id),
        .imm_type_in(imm_type_id),
        .imm_in(imm_id),
        .alu_src1_sel_in(alu_src1_sel_id),
        .alu_src2_sel_in(alu_src2_sel_id),
        .alu_src1_in(0),
        .alu_src2_in(0),
        .alu_func_in(alu_func_id),
        .alu_ans_in(0),
        .pc_add4_in(pc_add4_id),
        .pc_br_in(0),
        .pc_jal_in(pc_jal_id),
        .pc_jalr_in(0),
        .jal_in(jal_id),
        .jalr_in(jalr_id),
        .br_type_in(br_type_id),
        .br_in(0),
        .pc_sel_in(0),
        .pc_next_in(0),
        .dm_addr_in(0),
        .dm_din_in(0),
        .dm_dout_in(0),
        .dm_we_in(dm_we_id),
        .dm_type_in(dm_type_id),
        .pc_cur_out(pc_cur_ex),
        .inst_out(inst_ex),
        .rf_ra0_out(rf_ra0_ex),
        .rf_ra1_out(rf_ra1_ex),
        .rf_re0_out(rf_re0_ex),
        .rf_re1_out(rf_re1_ex),
        .rf_rd0_raw_out(rf_rd0_raw_ex),
        .rf_rd1_raw_out(rf_rd1_raw_ex),
        // .rf_rd0_out(),
        // .rf_rd1_out(),
        .rf_wa_out(rf_wa_ex),
        .rf_wd_sel_out(rf_wd_sel_ex),
        .rf_we_out(rf_we_ex),
        .imm_type_out(imm_type_ex),
        .imm_out(imm_ex),
        .alu_src1_sel_out(alu_src1_sel_ex),
        .alu_src2_sel_out(alu_src2_sel_ex),
        // .alu_src1_out(),
        // .alu_src2_out(),
        .alu_func_out(alu_func_ex),
        // .alu_ans_out(),
        .pc_add4_out(pc_add4_ex),
        // .pc_br_out(),
        .pc_jal_out(pc_jal_ex),
        // .pc_jalr_out(),
        .jal_out(jal_ex),
        .jalr_out(jalr_ex),
        .br_type_out(br_type_ex),
        // .br_out(),
        // .pc_sel_out(),
        // .pc_next_out(),
        // .dm_addr_out(),
        // .dm_din_out(),
        // .dm_dout_out(),
        .dm_we_out(dm_we_ex),
        .dm_type_out(dm_type_ex)
    );
    MUX1 rf_rd0_fwd(
        .sel(rf_rd0_fe),
        .src0(rf_rd0_raw_ex),
        .src1(rf_rd0_fd),
        .res(rf_rd0_ex)
    );
    MUX1 rf_rd1_fwd(
        .sel(rf_rd1_fe),
        .src0(rf_rd1_raw_ex),
        .src1(rf_rd1_fd),
        .res(rf_rd1_ex)
    );
    MUX1 alu_sel1(
        .sel(alu_src1_sel_ex),
        .src0(rf_rd0_ex),
        .src1(pc_cur_ex),
        .res(alu_src1_ex)
    );
    MUX1 alu_sel2(
        .sel(alu_src2_sel_ex),
        .src0(rf_rd1_ex),
        .src1(imm_ex),
        .res(alu_src2_ex)
    );
    ALU alu(
        .src1(alu_src1_ex),
        .src2(alu_src2_ex),
        .func(alu_func_ex),
        .ans(alu_ans_ex)
    );
    Branch branch(
        .type(br_type_ex),
        .op1(rf_rd0_ex),
        .op2(rf_rd1_ex),
        .br(br_ex)
    );
    Encoder pc_sel_gen(
        .jal(jal_id),
        .jalr(jalr_ex),
        .br(br_ex),
        .pc_sel(pc_sel_ex)
    );
    AND ander(
        .lhs(32'hfffffffe),
        .rhs(alu_ans_ex),
        .res(pc_jalr_ex)
    );
    MUX2 npc_sel(
        .sel(pc_sel_ex),
        .src0(pc_add4_if),
        .src1(pc_jalr_ex),
        .src2(alu_ans_ex),
        .src3(pc_jal_id),
        .res(pc_next)
    );
    SEG_REG seg_reg_ex_mem(
        .clk(clk),
        .flush(flush_mem),
        .stall(0),
        .pc_cur_in(pc_cur_ex),
        .inst_in(inst_ex),
        .rf_ra0_in(rf_ra0_ex),
        .rf_ra1_in(rf_ra1_ex),
        .rf_re0_in(rf_re0_ex),
        .rf_re1_in(rf_re1_ex),
        .rf_rd0_raw_in(rf_rd0_raw_ex),
        .rf_rd1_raw_in(rf_rd1_raw_ex),
        .rf_rd0_in(rf_rd0_ex),
        .rf_rd1_in(rf_rd1_ex),
        .rf_wa_in(rf_wa_ex),
        .rf_wd_sel_in(rf_wd_sel_ex),
        .rf_we_in(rf_we_ex),
        .imm_type_in(imm_type_ex),
        .imm_in(imm_ex),
        .alu_src1_sel_in(alu_src1_sel_ex),
        .alu_src2_sel_in(alu_src2_sel_ex),
        .alu_src1_in(alu_src1_ex),
        .alu_src2_in(alu_src2_ex),
        .alu_func_in(alu_func_ex),
        .alu_ans_in(alu_ans_ex),
        .pc_add4_in(pc_add4_ex),
        .pc_br_in(alu_ans_ex),
        .pc_jal_in(pc_jal_ex),
        .pc_jalr_in(pc_jalr_ex),
        .jal_in(jal_ex),
        .jalr_in(jalr_ex),
        .br_type_in(br_type_ex),
        .br_in(br_ex),
        .pc_sel_in(pc_sel_ex),
        .pc_next_in(pc_next),
        .dm_addr_in(alu_ans_ex),
        .dm_din_in(rf_rd1_ex),
        .dm_dout_in(0),
        .dm_we_in(dm_we_ex),
        .dm_type_in(dm_type_ex),
        .pc_cur_out(pc_cur_mem),
        .inst_out(inst_mem),
        .rf_ra0_out(rf_ra0_mem),
        .rf_ra1_out(rf_ra1_mem),
        .rf_re0_out(rf_re0_mem),
        .rf_re1_out(rf_re1_mem),
        .rf_rd0_raw_out(rf_rd0_raw_mem),
        .rf_rd1_raw_out(rf_rd1_raw_mem),
        .rf_rd0_out(rf_rd0_mem),
        .rf_rd1_out(rf_rd1_mem),
        .rf_wa_out(rf_wa_mem),
        .rf_wd_sel_out(rf_wd_sel_mem),
        .rf_we_out(rf_we_mem),
        .imm_type_out(imm_type_mem),
        .imm_out(imm_mem),
        .alu_src1_sel_out(alu_src1_sel_mem),
        .alu_src2_sel_out(alu_src2_sel_mem),
        .alu_src1_out(alu_src1_mem),
        .alu_src2_out(alu_src2_mem),
        .alu_func_out(alu_func_mem),
        .alu_ans_out(alu_ans_mem),
        .pc_add4_out(pc_add4_mem),
        .pc_br_out(pc_br_mem),
        .pc_jal_out(pc_jal_mem),
        .pc_jalr_out(pc_jalr_mem),
        .jal_out(jal_mem),
        .jalr_out(jalr_mem),
        .br_type_out(br_type_mem),
        .br_out(br_mem),
        .pc_sel_out(pc_sel_mem),
        .pc_next_out(pc_next_mem),
        .dm_addr_out(dm_addr_mem),
        .dm_din_out(dm_din_mem),
        // .dm_dout_out(),
        .dm_we_out(dm_we_mem),
        .dm_type_out(dm_type_mem)
    );
    SEG_REG seg_reg_mem_wb(
        .clk(clk),
        .flush(0),
        .stall(0),
        .pc_cur_in(pc_cur_mem),
        .inst_in(inst_mem),
        .rf_ra0_in(rf_ra0_mem),
        .rf_ra1_in(rf_ra1_mem),
        .rf_re0_in(rf_re0_mem),
        .rf_re1_in(rf_re1_mem),
        .rf_rd0_raw_in(rf_rd0_raw_mem),
        .rf_rd1_raw_in(rf_rd1_raw_mem),
        .rf_rd0_in(rf_rd0_mem),
        .rf_rd1_in(rf_rd1_mem),
        .rf_wa_in(rf_wa_mem),
        .rf_wd_sel_in(rf_wd_sel_mem),
        .rf_we_in(rf_we_mem),
        .imm_type_in(imm_type_mem),
        .imm_in(imm_mem),
        .alu_src1_sel_in(alu_src1_sel_mem),
        .alu_src2_sel_in(alu_src2_sel_mem),
        .alu_src1_in(alu_src1_mem),
        .alu_src2_in(alu_src2_mem),
        .alu_func_in(alu_func_mem),
        .alu_ans_in(alu_ans_mem),
        .pc_add4_in(pc_add4_mem),
        .pc_br_in(pc_br_mem),
        .pc_jal_in(pc_jal_mem),
        .pc_jalr_in(pc_jalr_mem),
        .jal_in(jal_mem),
        .jalr_in(jalr_mem),
        .br_type_in(br_type_mem),
        .br_in(br_mem),
        .pc_sel_in(pc_sel_mem),
        .pc_next_in(pc_next_mem),
        .dm_addr_in(dm_addr_mem),
        .dm_din_in(dm_din_mem),
        .dm_dout_in(dm_dout),
        .dm_we_in(dm_we_mem),
        .dm_type_in(dm_type_mem),
        .pc_cur_out(pc_cur_wb),
        .inst_out(inst_wb),
        .rf_ra0_out(rf_ra0_wb),
        .rf_ra1_out(rf_ra1_wb),
        .rf_re0_out(rf_re0_wb),
        .rf_re1_out(rf_re1_wb),
        .rf_rd0_raw_out(rf_rd0_raw_wb),
        .rf_rd1_raw_out(rf_rd1_raw_wb),
        .rf_rd0_out(rf_rd0_wb),
        .rf_rd1_out(rf_rd1_wb),
        .rf_wa_out(rf_wa_wb),
        .rf_wd_sel_out(rf_wd_sel_wb),
        .rf_we_out(rf_we_wb),
        .imm_type_out(imm_type_wb),
        .imm_out(imm_wb),
        .alu_src1_sel_out(alu_src1_sel_wb),
        .alu_src2_sel_out(alu_src2_sel_wb),
        .alu_src1_out(alu_src1_wb),
        .alu_src2_out(alu_src2_wb),
        .alu_func_out(alu_func_wb),
        .alu_ans_out(alu_ans_wb),
        .pc_add4_out(pc_add4_wb),
        .pc_br_out(pc_br_wb),
        .pc_jal_out(pc_jal_wb),
        .pc_jalr_out(pc_jalr_wb),
        .jal_out(jal_wb),
        .jalr_out(jalr_wb),
        .br_type_out(br_type_wb),
        .br_out(br_wb),
        .pc_sel_out(pc_sel_wb),
        .pc_next_out(pc_next_wb),
        .dm_addr_out(dm_addr_wb),
        .dm_din_out(dm_din_wb),
        .dm_dout_out(dm_dout_wb),
        .dm_we_out(dm_we_wb),
        .dm_type_out(dm_type_wb)
    );
    MUX2 reg_write_sel(
        .sel(rf_wd_sel_wb),
        .src0(alu_ans_wb),
        .src1(pc_add4_wb),
        .src2(dm_dout_wb),
        .src3(imm_wb),
        .res(rf_wd_wb)
    );
    Hazard hazard(
        .rf_ra0_ex(rf_ra0_ex),
        .rf_ra1_ex(rf_ra1_ex),
        .rf_ra0_id(rf_ra0_id),
        .rf_ra1_id(rf_ra1_id),
        .rf_re0_ex(rf_re0_ex),
        .rf_re1_ex(rf_re1_ex),
        .rf_re0_id(rf_re0_id),
        .rf_re1_id(rf_re1_id),
        .rf_wa_mem(rf_wa_mem),
        .rf_wa_ex(rf_wa_ex),
        .rf_we_mem(rf_we_mem),
        .rf_we_ex(rf_we_ex),
        .rf_wd_sel_mem(rf_wd_sel_mem),
        .rf_wd_sel_ex(rf_wd_sel_ex),
        .alu_ans_mem(alu_ans_mem),
        .pc_add4_mem(pc_add4_mem),
        .imm_mem(imm_mem),
        .rf_wa_wb(rf_wa_wb),
        .rf_we_wb(rf_we_wb),
        .rf_wd_wb(rf_wd_wb),
        .pc_sel_ex(pc_sel_ex),
        .rf_rd0_fe(rf_rd0_fe),
        .rf_rd1_fe(rf_rd1_fe),
        .rf_rd0_fd(rf_rd0_fd),
        .rf_rd1_fd(rf_rd1_fd),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .stall_ex(stall_ex),
        .flush_if(flush_if),
        .flush_id(flush_id),
        .flush_ex(flush_ex),
        .flush_mem(flush_mem)
    );
    Check_Data_SEL check_data_sel_if(
        .check_addr(cpu_check_addr[4:0]),
        .pc_cur(pc_cur_if),
        .instruction(inst_if),
        .rf_ra0(inst_if[19:15]),
        .rf_ra1(inst_if[24:20]),
        .rf_re0(0),
        .rf_re1(0),
        .rf_rd0_raw(0),
        .rf_rd1_raw(0),
        .rf_rd0(0),
        .rf_rd1(0),
        .rf_wa(inst_if[11:7]),
        .rf_wd_sel(0),
        .rf_wd(0),
        .rf_we(0),
        .immediate(0),
        .alu_src1(0),
        .alu_src2(0),
        .alu_func(0),
        .alu_ans(0),
        .pc_add4(pc_add4_if),
        .pc_br(0),
        .pc_jal(0),
        .pc_jalr(0),
        .pc_sel(0),
        .pc_next(0),
        .dm_addr(0),
        .dm_din(0),
        .dm_dout(0),
        .dm_we(0),
        .dm_type(0),
        .check_data(check_data_if)
    );
    Check_Data_SEL check_data_sel_id(
        .check_addr(cpu_check_addr[4:0]),
        .pc_cur(pc_cur_id),
        .instruction(inst_id),
        .rf_ra0(rf_ra0_id),
        .rf_ra1(rf_ra1_id),
        .rf_re0(rf_re0_id),
        .rf_re1(rf_re1_id),
        .rf_rd0_raw(rf_rd0_raw_id),
        .rf_rd1_raw(rf_rd1_raw_id),
        .rf_rd0(0),
        .rf_rd1(0),
        .rf_wa(rf_wa_id),
        .rf_wd_sel(rf_wd_sel_id),
        .rf_wd(0),
        .rf_we(rf_we_id),
        .immediate(imm_id),
        .alu_src1(0),
        .alu_src2(0),
        .alu_func(alu_func_id),
        .alu_ans(0),
        .pc_add4(pc_add4_id),
        .pc_br(0),
        .pc_jal(pc_jal_id),
        .pc_jalr(0),
        .pc_sel(0),
        .pc_next(0),
        .dm_addr(0),
        .dm_din(rf_rd1_raw_id),
        .dm_dout(0),
        .dm_we(dm_we_id),
        .dm_type(dm_type_id),
        .check_data(check_data_id)
    );
    Check_Data_SEL check_data_sel_ex(
        .check_addr(cpu_check_addr[4:0]),
        .pc_cur(pc_cur_ex),
        .instruction(inst_ex),
        .rf_ra0(rf_ra0_ex),
        .rf_ra1(rf_ra1_ex),
        .rf_re0(rf_re0_ex),
        .rf_re1(rf_re1_ex),
        .rf_rd0_raw(rf_rd0_raw_ex),
        .rf_rd1_raw(rf_rd1_raw_ex),
        .rf_rd0(rf_rd0_ex),
        .rf_rd1(rf_rd1_ex),
        .rf_wa(rf_wa_ex),
        .rf_wd_sel(rf_wd_sel_ex),
        .rf_wd(0),
        .rf_we(rf_we_ex),
        .immediate(imm_ex),
        .alu_src1(alu_src1_ex),
        .alu_src2(alu_src2_ex),
        .alu_func(alu_func_ex),
        .alu_ans(alu_ans_ex),
        .pc_add4(pc_add4_ex),
        .pc_br(alu_ans_ex),
        .pc_jal(pc_jal_ex),
        .pc_jalr(pc_jalr_ex),
        .pc_sel(pc_sel_ex),
        .pc_next(pc_next),
        .dm_addr(alu_ans_ex),
        .dm_din(rf_rd1_ex),
        .dm_dout(0),
        .dm_we(dm_we_ex),
        .dm_type(dm_type_ex),
        .check_data(check_data_ex)
    );
    Check_Data_SEL check_data_sel_mem(
        .check_addr(cpu_check_addr[4:0]),
        .pc_cur(pc_cur_mem),
        .instruction(inst_mem),
        .rf_ra0(rf_ra0_mem),
        .rf_ra1(rf_ra1_mem),
        .rf_re0(rf_re0_mem),
        .rf_re1(rf_re1_mem),
        .rf_rd0_raw(rf_rd0_raw_mem),
        .rf_rd1_raw(rf_rd1_raw_mem),
        .rf_rd0(rf_rd0_mem),
        .rf_rd1(rf_rd1_mem),
        .rf_wa(rf_wa_mem),
        .rf_wd_sel(rf_wd_sel_mem),
        .rf_wd(0),
        .rf_we(rf_we_mem),
        .immediate(imm_mem),
        .alu_src1(alu_src1_mem),
        .alu_src2(alu_src2_mem),
        .alu_func(alu_func_mem),
        .alu_ans(alu_ans_mem),
        .pc_add4(pc_add4_mem),
        .pc_br(pc_br_mem),
        .pc_jal(pc_jal_mem),
        .pc_jalr(pc_jalr_mem),
        .pc_sel(pc_sel_mem),
        .pc_next(pc_next_mem),
        .dm_addr(dm_addr_mem),
        .dm_din(dm_din_mem),
        .dm_dout(dm_dout),
        .dm_we(dm_we_mem),
        .dm_type(dm_type_mem),
        .check_data(check_data_mem)
    );
    Check_Data_SEL check_data_sel_wb(
        .check_addr(cpu_check_addr[4:0]),
        .pc_cur(pc_cur_wb),
        .instruction(inst_wb),
        .rf_ra0(rf_ra0_wb),
        .rf_ra1(rf_ra1_wb),
        .rf_re0(rf_re0_wb),
        .rf_re1(rf_re1_wb),
        .rf_rd0_raw(rf_rd0_raw_wb),
        .rf_rd1_raw(rf_rd1_raw_wb),
        .rf_rd0(rf_rd0_wb),
        .rf_rd1(rf_rd1_wb),
        .rf_wa(rf_wa_wb),
        .rf_wd_sel(rf_wd_sel_wb),
        .rf_wd(rf_wd_wb),
        .rf_we(rf_we_wb),
        .immediate(imm_wb),
        .alu_src1(alu_src1_wb),
        .alu_src2(alu_src2_wb),
        .alu_func(alu_func_wb),
        .alu_ans(alu_ans_wb),
        .pc_add4(pc_add4_wb),
        .pc_br(pc_br_wb),
        .pc_jal(pc_jal_wb),
        .pc_jalr(pc_jalr_wb),
        .pc_sel(pc_sel_wb),
        .pc_next(pc_next_wb),
        .dm_addr(dm_addr_wb),
        .dm_din(dm_din_wb),
        .dm_dout(dm_dout_wb),
        .dm_we(dm_we_wb),
        .dm_type(dm_type_wb),
        .check_data(check_data_wb)
    );
    Check_Data_SEL_HZD check_data_sel_hzd(
        .check_addr(cpu_check_addr[4:0]),
        .rf_ra0_ex(rf_ra0_ex),
        .rf_ra1_ex(rf_ra1_ex),
        .rf_re0_ex(rf_re0_ex),
        .rf_re1_ex(rf_re1_ex),
        .rf_wa_mem(rf_wa_mem),
        .rf_we_mem(rf_we_mem),
        .rf_wd_sel_mem(rf_wd_sel_mem),
        .alu_ans_mem(alu_ans_mem),
        .pc_add4_mem(pc_add4_mem),
        .imm_mem(imm_mem),
        .rf_wa_wb(rf_wa_wb),
        .rf_we_wb(rf_we_wb),
        .rf_wd_wb(rf_wd_wb),
        .rf_rd0_fe(rf_rd0_fe),
        .rf_rd1_fe(rf_rd1_fe),
        .rf_rd0_fd(rf_rd0_fd),
        .rf_rd1_fd(rf_rd1_fd),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .stall_ex(stall_ex),
        .flush_if(flush_if),
        .flush_id(flush_id),
        .flush_ex(flush_ex),
        .flush_mem(flush_mem),
        .pc_sel_ex(pc_sel_ex),
        .check_data(check_data_hzd)
    );
    Check_Data_SEG_SEL check_data_seg_sel(
        .sel(cpu_check_addr[7:5]),
        .check_data_if(check_data_if),
        .check_data_id(check_data_id),
        .check_data_ex(check_data_ex),
        .check_data_mem(check_data_mem),
        .check_data_wb(check_data_wb),
        .check_data_hzd(check_data_hzd),
        .check_data(check_data)
    );
    MUX1 cpu_check_data_sel(
        .sel(cpu_check_addr[12]),
        .src0(check_data),
        .src1(rf_rd_dbg_id),
        .res(cpu_check_data)
    );

    assign im_addr = pc_cur_if;
    assign mem_addr = alu_ans_mem;
    assign mem_din = dm_din_mem;
    assign mem_we = dm_we_mem;
    assign mem_type = dm_type_mem;
    assign current_pc = pc_cur_if;
    assign next_pc = pc_next;
endmodule

module PC (
    input clk,rst,stall,
    input[31:0] pc_next,
    output reg[31:0] pc_cur
);
    always @(posedge clk or posedge rst) begin
        if (rst) pc_cur <= 32'h2ffc;
        else if (!stall) pc_cur <= pc_next;
    end
endmodule

module RF (
    input clk,we,
    input[4:0] ra0,ra1,wa,ra_dbg,
    input[31:0] wd,
    output [31:0] rd0,rd1,rd_dbg
);
    reg[31:0] rf[31:0];
    assign rd0 = ra0?((we && wa==ra0)?wd:rf[ra0]):0;
    assign rd1 = ra1?((we && wa==ra1)?wd:rf[ra1]):0;
    assign rd_dbg = ra_dbg?((we && wa==ra_dbg)?wd:rf[ra_dbg]):0;
    always @(posedge clk) begin
        if (we) rf[wa] <= wd;
    end
    integer i;
    initial begin
        i = 0;
        while (i<32) begin
            rf[i] = 32'b0;
            i = i+1;
        end
        rf[2] = 32'h2ffc;
        rf[3] = 32'h1800;
    end
endmodule

module CTRL (
    input[31:0] inst,
    output reg rf_re0,rf_re1,rf_we,
    output reg[1:0] rf_wd_sel,
    output reg[2:0] imm_type,
    output reg jal,jalr,
    output reg[2:0] br_type,
    output reg alu_src1_sel,alu_src2_sel,
    output reg[3:0] alu_func,
    output reg mem_we,
    output reg[2:0] mem_type
);
    wire[6:0] opcode;
    wire[2:0] funct3;
    wire[6:0] funct7;
    wire[4:0] rs0,rs1,rd;
    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];
    assign rs0 = inst[19:15];
    assign rs1 = inst[24:20];
    assign rd = inst[11:7];
    always @(*) begin
        rf_re0 = 0;
        rf_re1 = 0;
        rf_we = 0;
        rf_wd_sel = 0;
        imm_type = 0;
        jal = 0;
        jalr = 0;
        br_type = 0;
        alu_src1_sel = 0;
        alu_src2_sel = 0;
        alu_func = 0;
        mem_we = 0;
        mem_type = 0;
        case (opcode)
            // R
            7'b0110011: begin
                if (rs0) rf_re0 = 1;
                if (rs1) rf_re1 = 1;
                if (rd) rf_we = 1;
                alu_func = {funct7[5],funct3};
            end
            // I-AL
            7'b0010011: begin
                if (rs0) rf_re0 = 1;
                if (rd) rf_we = 1;
                imm_type = 1;
                alu_src2_sel = 1;
                alu_func = {1'b0,funct3};
                if (funct3==3'h5) alu_func[3] = inst[30];
            end
            // I-Load
            7'b0000011: begin
                if (rs0) rf_re0 = 1;
                if (rd) rf_we = 1;
                rf_wd_sel = 2;
                imm_type = 1;
                alu_src2_sel = 1;
                mem_type = funct3;
            end
            // S
            7'b0100011: begin
                if (rs0) rf_re0 = 1;
                if (rs1) rf_re1 = 1;
                imm_type = 2;
                alu_src2_sel = 1;
                mem_we = 1;
                mem_type = funct3;
            end
            // B
            7'b1100011: begin
                if (rs0) rf_re0 = 1;
                if (rs1) rf_re1 = 1;
                imm_type = 3;
                br_type = funct3^2;
                alu_src1_sel = 1;
                alu_src2_sel = 1;
            end
            // J
            7'b1101111: begin
                if (rd) rf_we = 1;
                rf_wd_sel = 1;
                imm_type = 5;
                jal = 1;
                alu_src1_sel = 1;
                alu_src2_sel = 1;
            end
            // I-jalr
            7'b1100111: begin
                if (rs0) rf_re0 = 1;
                if (rd) rf_we = 1;
                rf_wd_sel = 1;
                imm_type = 1;
                jalr = 1;
                alu_src2_sel = 1;
            end
            // U-lui
            7'b0110111: begin
                if (rd) rf_we = 1;
                rf_wd_sel = 3;
                imm_type = 4;
            end
            // U-auipc
            7'b0010111: begin
                if (rd) rf_we = 1;
                imm_type = 4;
                alu_src1_sel = 1;
                alu_src2_sel = 1;
            end
        endcase
    end
endmodule

module Immediate (
    input[2:0] type,
    input[31:0] inst,
    output reg[31:0] imm
);
    always @(*) begin
        case (type)
            // I
            1: imm = {{20{inst[31]}},inst[31:20]};
            // S
            2: imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
            // B
            3: imm = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
            // U
            4: imm = {inst[31:12],12'b0};
            // J
            5: imm = {{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
            // R
            default: imm = 32'b0;
        endcase
    end
endmodule

module ALU (
    input[31:0] src1,src2,
    input[3:0] func,
    output reg[31:0] ans
);
    always @(*) begin
        case (func)
            // add
            4'h0: ans = src1+src2;
            // sub
            4'h8: ans = src1-src2;
            // xor
            4'h4: ans = src1^src2;
            // or
            4'h6: ans = src1|src2;
            // and
            4'h7: ans = src1&src2;
            // sll
            4'h1: ans = src1<<src2[4:0];
            // srl
            4'h5: ans = src1>>src2[4:0];
            // sra
            4'hd: ans = $signed(src1)>>>src2[4:0];
            // slt
            4'h2: ans = $signed(src1)<$signed(src2);
            // sltu
            4'h3: ans = src1<src2;
            default: ans = 0;
        endcase
    end
endmodule

module Branch (
    input[2:0] type,
    input[31:0] op1,op2,
    output reg br
);
    // type: funct3^2
    always @(*) begin
        case (type)
            // eq
            3'h2: br = op1==op2;
            // ne
            3'h3: br = op1!=op2;
            // lt
            3'h6: br = $signed(op1)<$signed(op2);
            // ge
            3'h7: br = $signed(op1)>=$signed(op2);
            // ltu
            3'h4: br = op1<op2;
            // geu
            3'h5: br = op1>=op2;
            default: br = 0;
        endcase
    end
endmodule

module Encoder (
    input jal,jalr,br,
    output reg[1:0] pc_sel
);
    always @(*) begin
        pc_sel = 0;
        // jal_id
        if (jal) pc_sel = 3;
        // jalr_ex
        if (jalr) pc_sel = 1;
        // br_ex
        if (br) pc_sel = 2;
    end
endmodule

module MUX1 (
    input sel,
    input[31:0] src0,src1,
    output[31:0] res
);
    assign res = sel?src1:src0;
endmodule

module MUX2 (
    input[1:0] sel,
    input[31:0] src0,src1,src2,src3,
    output[31:0] res
);
    assign res = sel[1]?(sel[0]?src3:src2):(sel[0]?src1:src0);
endmodule

module ADD (
    input[31:0] lhs,rhs,
    output[31:0] res
);
    assign res = lhs+rhs;
endmodule

module AND (
    input[31:0] lhs,rhs,
    output[31:0] res
);
    assign res = lhs&rhs;
endmodule

module SEG_REG (
    input clk,flush,stall,
    input[31:0] pc_cur_in,
    input[31:0] inst_in,
    input[4:0] rf_ra0_in,rf_ra1_in,
    input rf_re0_in,rf_re1_in,
    input[31:0] rf_rd0_raw_in,rf_rd1_raw_in,
    input[31:0] rf_rd0_in,rf_rd1_in,
    input[4:0] rf_wa_in,
    input[1:0] rf_wd_sel_in,
    input rf_we_in,
    input[2:0] imm_type_in,
    input[31:0] imm_in,
    input alu_src1_sel_in,alu_src2_sel_in,
    input[31:0] alu_src1_in,alu_src2_in,
    input[3:0] alu_func_in,
    input[31:0] alu_ans_in,
    input[31:0] pc_add4_in,pc_br_in,pc_jal_in,pc_jalr_in,
    input jal_in,jalr_in,
    input[2:0] br_type_in,
    input br_in,
    input[1:0] pc_sel_in,
    input[31:0] pc_next_in,
    input[31:0] dm_addr_in,
    input[31:0] dm_din_in,dm_dout_in,
    input dm_we_in,
    input[2:0] dm_type_in,
    output reg[31:0] pc_cur_out,
    output reg[31:0] inst_out,
    output reg[4:0] rf_ra0_out,rf_ra1_out,
    output reg rf_re0_out,rf_re1_out,
    output reg[31:0] rf_rd0_raw_out,rf_rd1_raw_out,
    output reg[31:0] rf_rd0_out,rf_rd1_out,
    output reg[4:0] rf_wa_out,
    output reg[1:0] rf_wd_sel_out,
    output reg rf_we_out,
    output reg[2:0] imm_type_out,
    output reg[31:0] imm_out,
    output reg alu_src1_sel_out,alu_src2_sel_out,
    output reg[31:0] alu_src1_out,alu_src2_out,
    output reg[3:0] alu_func_out,
    output reg[31:0] alu_ans_out,
    output reg[31:0] pc_add4_out,pc_br_out,pc_jal_out,pc_jalr_out,
    output reg jal_out,jalr_out,
    output reg[2:0] br_type_out,
    output reg br_out,
    output reg[1:0] pc_sel_out,
    output reg[31:0] pc_next_out,
    output reg[31:0] dm_addr_out,
    output reg[31:0] dm_din_out,dm_dout_out,
    output reg dm_we_out,
    output reg[2:0] dm_type_out
);
    always @(posedge clk) begin
        if (flush) begin
            pc_cur_out <= 0;
            inst_out <= 0;
            rf_ra0_out <= 0;
            rf_ra1_out <= 0;
            rf_re0_out <= 0;
            rf_re1_out <= 0;
            rf_rd0_raw_out <= 0;
            rf_rd1_raw_out <= 0;
            rf_rd0_out <= 0;
            rf_rd1_out <= 0;
            rf_wa_out <= 0;
            rf_wd_sel_out <= 0;
            rf_we_out <= 0;
            imm_type_out <= 0;
            imm_out <= 0;
            alu_src1_sel_out <= 0;
            alu_src2_sel_out <= 0;
            alu_src1_out <= 0;
            alu_src2_out <= 0;
            alu_func_out <= 0;
            alu_ans_out <= 0;
            pc_add4_out <= 0;
            pc_br_out <= 0;
            pc_jal_out <= 0;
            pc_jalr_out <= 0;
            jal_out <= 0;
            jalr_out <= 0;
            br_type_out <= 0;
            br_out <= 0;
            pc_sel_out <= 0;
            pc_next_out <= 0;
            dm_addr_out <= 0;
            dm_din_out <= 0;
            dm_dout_out <= 0;
            dm_we_out <= 0;
            dm_type_out <= 0;
        end else if (!stall) begin
            pc_cur_out <= pc_cur_in;
            inst_out <= inst_in;
            rf_ra0_out <= rf_ra0_in;
            rf_ra1_out <= rf_ra1_in;
            rf_re0_out <= rf_re0_in;
            rf_re1_out <= rf_re1_in;
            rf_rd0_raw_out <= rf_rd0_raw_in;
            rf_rd1_raw_out <= rf_rd1_raw_in;
            rf_rd0_out <= rf_rd0_in;
            rf_rd1_out <= rf_rd1_in;
            rf_wa_out <= rf_wa_in;
            rf_wd_sel_out <= rf_wd_sel_in;
            rf_we_out <= rf_we_in;
            imm_type_out <= imm_type_in;
            imm_out <= imm_in;
            alu_src1_sel_out <= alu_src1_sel_in;
            alu_src2_sel_out <= alu_src2_sel_in;
            alu_src1_out <= alu_src1_in;
            alu_src2_out <= alu_src2_in;
            alu_func_out <= alu_func_in;
            alu_ans_out <= alu_ans_in;
            pc_add4_out <= pc_add4_in;
            pc_br_out <= pc_br_in;
            pc_jal_out <= pc_jal_in;
            pc_jalr_out <= pc_jalr_in;
            jal_out <= jal_in;
            jalr_out <= jalr_in;
            br_type_out <= br_type_in;
            br_out <= br_in;
            pc_sel_out <= pc_sel_in;
            pc_next_out <= pc_next_in;
            dm_addr_out <= dm_addr_in;
            dm_din_out <= dm_din_in;
            dm_dout_out <= dm_dout_in;
            dm_we_out <= dm_we_in;
            dm_type_out <= dm_type_in;
        end
    end
endmodule

module Hazard (
    input[4:0] rf_ra0_ex,rf_ra1_ex,rf_ra0_id,rf_ra1_id,
    input rf_re0_ex,rf_re1_ex,rf_re0_id,rf_re1_id,
    input[4:0] rf_wa_mem,rf_wa_ex,
    input rf_we_mem,rf_we_ex,
    input[1:0] rf_wd_sel_mem,rf_wd_sel_ex,
    input[31:0] alu_ans_mem,
    input[31:0] pc_add4_mem,
    input[31:0] imm_mem,
    input[4:0] rf_wa_wb,
    input rf_we_wb,
    input[31:0] rf_wd_wb,
    input[1:0] pc_sel_ex,
    output reg rf_rd0_fe,rf_rd1_fe,
    output reg[31:0] rf_rd0_fd,rf_rd1_fd,
    output reg stall_if,stall_id,stall_ex,
    output reg flush_if,flush_id,flush_ex,flush_mem
);
    always @(*) begin
        rf_rd0_fe = 0;
        rf_rd1_fe = 0;
        rf_rd0_fd = 0;
        rf_rd1_fd = 0;
        stall_if = 0;
        stall_id = 0;
        stall_ex = 0;
        flush_if = 0;
        flush_id = 0;
        flush_ex = 0;
        flush_mem = 0;
        // Control Hazard
        if (pc_sel_ex!=2'b00) begin
            flush_id = 1;
            // not jal
            if (pc_sel_ex!=2'b11) flush_ex = 1;
        end
        // Data Hazard
        if (rf_we_mem && rf_re0_ex && rf_wa_mem==rf_ra0_ex) begin
            // MEM->EX
            rf_rd0_fe = 1;
            case (rf_wd_sel_mem)
                0: rf_rd0_fd = alu_ans_mem;
                1: rf_rd0_fd = pc_add4_mem;
                // 2: rf_rd0_fd = dm_dout_mem;
                3: rf_rd0_fd = imm_mem;
            endcase
        end else if (rf_we_wb && rf_re0_ex && rf_wa_wb==rf_ra0_ex) begin
            // WB->EX
            rf_rd0_fe = 1;
            rf_rd0_fd = rf_wd_wb;
        end
        if (rf_we_mem && rf_re1_ex && rf_wa_mem==rf_ra1_ex) begin
            // MEM->EX
            rf_rd1_fe = 1;
            case (rf_wd_sel_mem)
                0: rf_rd1_fd = alu_ans_mem;
                1: rf_rd1_fd = pc_add4_mem;
                // 2: rf_rd1_fd = dm_dout_mem;
                3: rf_rd1_fd = imm_mem;
            endcase
        end else if (rf_we_wb && rf_re1_ex && rf_wa_wb==rf_ra1_ex) begin
            // WB->EX
            rf_rd1_fe = 1;
            rf_rd1_fd = rf_wd_wb;
        end
        // Load-Use Hazard
        if ((rf_we_ex && rf_wd_sel_ex==2 && rf_re0_id && rf_wa_ex==rf_ra0_id)||
            (rf_we_ex && rf_wd_sel_ex==2 && rf_re1_id && rf_wa_ex==rf_ra1_id)) begin
            stall_if = 1;
            stall_id = 1;
            flush_ex = 1;
        end
    end
    initial begin
        flush_if = 1;
        flush_id = 1;
        flush_ex = 1;
        flush_mem = 1;
    end
endmodule

module Check_Data_SEL (
    input [31:0]                pc_cur,
    input [31:0]                instruction,
    input [4:0]                 rf_ra0,
    input [4:0]                 rf_ra1,
    input                       rf_re0,
    input                       rf_re1,
    input [31:0]                rf_rd0_raw,
    input [31:0]                rf_rd1_raw,
    input [31:0]                rf_rd0,
    input [31:0]                rf_rd1,
    input [4:0]                 rf_wa,
    input [1:0]                 rf_wd_sel,
    input [31:0]                rf_wd,
    input                       rf_we,
    input [31:0]                immediate,
    input [31:0]                alu_src1,
    input [31:0]                alu_src2,
    input [3:0]                 alu_func,
    input [31:0]                alu_ans,
    input [31:0]                pc_add4,
    input [31:0]                pc_br,
    input [31:0]                pc_jal,
    input [31:0]                pc_jalr,
    input [1:0]                 pc_sel,
    input [31:0]                pc_next,
    input [31:0]                dm_addr,
    input [31:0]                dm_din,
    input [31:0]                dm_dout,
    input                       dm_we,
    input [2:0]                 dm_type,

    input [4:0]                 check_addr,
    output reg [31:0]           check_data
);
    always @(*) begin
        check_data = 0;     // Default value

        case (check_addr)
            5'd0: check_data = pc_cur;
            5'd1: check_data = instruction;
            5'd2: check_data = rf_ra0;
            5'd3: check_data = rf_ra1;
            5'd4: check_data = rf_re0;
            5'd5: check_data = rf_re1;
            5'd6: check_data = rf_rd0_raw;
            5'd7: check_data = rf_rd1_raw;
            5'd8: check_data = rf_rd0;
            5'd9: check_data = rf_rd1;
            5'd10: check_data = rf_wa;
            5'd11: check_data = rf_wd_sel;
            5'd12: check_data = rf_wd;
            5'd13: check_data = rf_we;
            5'd14: check_data = immediate;
            5'd15: check_data = alu_src1;
            5'd16: check_data = alu_src2;
            5'd17: check_data = alu_func;
            5'd18: check_data = alu_ans;
            5'd19: check_data = pc_add4;
            5'd20: check_data = pc_br;
            5'd21: check_data = pc_jal;
            5'd22: check_data = pc_jalr;
            5'd23: check_data = pc_sel;
            5'd24: check_data = pc_next;
            5'd25: check_data = dm_addr;
            5'd26: check_data = dm_din;
            5'd27: check_data = dm_dout;
            5'd28: check_data = dm_we;
            5'd29: check_data = dm_type;
        endcase
    end
endmodule

module Check_Data_SEG_SEL (
    input [31:0]            check_data_if,
    input [31:0]            check_data_id,
    input [31:0]            check_data_ex,
    input [31:0]            check_data_mem,
    input [31:0]            check_data_wb,
    input [31:0]            check_data_hzd,

    input [2:0]             sel,
    output reg [31:0]       check_data
);
    always @(*) begin
        check_data = 0;     // Default value

        case (sel)
            3'd0: check_data = check_data_if;
            3'd1: check_data = check_data_id;
            3'd2: check_data = check_data_ex;
            3'd3: check_data = check_data_mem;
            3'd4: check_data = check_data_wb;
            3'd5: check_data = check_data_hzd;
        endcase
    end
endmodule

module Check_Data_SEL_HZD (
    input [31:0]            rf_ra0_ex,
    input [31:0]            rf_ra1_ex,
    input                   rf_re0_ex,
    input                   rf_re1_ex,
    input [1:0]             pc_sel_ex,
    input [4:0]             rf_wa_mem,
    input                   rf_we_mem,
    input [1:0]             rf_wd_sel_mem,
    input [31:0]            alu_ans_mem,
    input [31:0]            pc_add4_mem,
    input [31:0]            imm_mem,
    input [4:0]             rf_wa_wb,
    input                   rf_we_wb,
    input [31:0]            rf_wd_wb,

    input                   rf_rd0_fe,
    input                   rf_rd1_fe,
    input [31:0]            rf_rd0_fd,
    input [31:0]            rf_rd1_fd,
    input                   stall_if,
    input                   stall_id,
    input                   stall_ex,
    input                   flush_if,
    input                   flush_id,
    input                   flush_ex,
    input                   flush_mem,

    input [4:0]             check_addr,
    output reg [31:0]       check_data
);
    always @(*) begin
        check_data = 0;     // Default value

        case (check_addr)
            5'd0: check_data = rf_ra0_ex;
            5'd1: check_data = rf_ra1_ex;
            5'd2: check_data = rf_re0_ex;
            5'd3: check_data = rf_re1_ex;
            5'd4: check_data = pc_sel_ex;
            5'd5: check_data = rf_wa_mem;
            5'd6: check_data = rf_we_mem;
            5'd7: check_data = rf_wd_sel_mem;
            5'd8: check_data = alu_ans_mem;
            5'd9: check_data = pc_add4_mem;
            5'd10: check_data = imm_mem;
            5'd11: check_data = rf_wa_wb;
            5'd12: check_data = rf_we_wb;
            5'd13: check_data = rf_wd_wb;

            5'd14: check_data = rf_rd0_fe;
            5'd15: check_data = rf_rd1_fe;
            5'd16: check_data = rf_rd0_fd;
            5'd17: check_data = rf_rd1_fd;
            5'd18: check_data = stall_if;
            5'd19: check_data = stall_id;
            5'd20: check_data = stall_ex;
            5'd21: check_data = flush_if;
            5'd22: check_data = flush_id;
            5'd23: check_data = flush_ex;
            5'd24: check_data = flush_mem;
        endcase
    end
endmodule