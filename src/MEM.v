module MEM(
    input clk,

    // MEM Data BUS with CPU
	// IM port
    input [31:0] im_addr,
    output [31:0] im_dout,

	// DM port
    input  [31:0] dm_addr,
    input dm_we,
    input  [2:0] dm_type,
    input  [31:0] dm_din,
    output reg[31:0] dm_dout,

    // MEM Debug BUS
    input [31:0] mem_check_addr,
    output [31:0] mem_check_data
);
    ROM inst_mem(
        .a          (im_addr[10:2]),
        .spo        (im_dout)
    );
    reg[3:0] dm_we_mask;
    wire[1:0] dm_wa_mask;
    wire[7:0] dm_din_byte[3:0];
    wire[7:0] dm_dout_byte[3:0];
    assign dm_wa_mask = (1<<dm_type[1:0])-1;
    assign dm_din_byte[0] = dm_din[7:0];
    assign dm_din_byte[1] = dm_din[15:8];
    assign dm_din_byte[2] = dm_din[23:16];
    assign dm_din_byte[3] = dm_din[31:24];
    always @(*) begin
        dm_we_mask = 4'b0;
        case (dm_type[1:0])
            0: dm_we_mask[dm_addr[1:0]] = 1'b1;
            1: {dm_we_mask[{dm_addr[1],1'b1}], dm_we_mask[{dm_addr[1],1'b0}]} = 2'b11;
            2: dm_we_mask = 4'b1111;
        endcase
    end
    always @(*) begin
        dm_dout = 32'b0;
        case (dm_type)
            0: dm_dout = $signed(dm_dout_byte[dm_addr[1:0]]);
            1: dm_dout = $signed({dm_dout_byte[{dm_addr[1],1'b1}], dm_dout_byte[{dm_addr[1],1'b0}]});
            2: dm_dout = $signed({dm_dout_byte[3], dm_dout_byte[2], dm_dout_byte[1], dm_dout_byte[0]});
            4: dm_dout = dm_dout_byte[dm_addr[1:0]];
            5: dm_dout = {dm_dout_byte[{dm_addr[1],1'b1}], dm_dout_byte[{dm_addr[1],1'b0}]};
        endcase
    end
    DPRAM data_mem0(
        .clk        (clk),
        .we         (dm_we & dm_we_mask[0]),
        .a          (dm_addr[9:2]),
        .d          (dm_din_byte[0 & dm_wa_mask]),
        .dpra       (mem_check_addr[9:2]),
        .spo        (dm_dout_byte[0]),
        .dpo        (mem_check_data[7:0])
    );
    DPRAM data_mem1(
        .clk        (clk),
        .we         (dm_we & dm_we_mask[1]),
        .a          (dm_addr[9:2]),
        .d          (dm_din_byte[1 & dm_wa_mask]),
        .dpra       (mem_check_addr[9:2]),
        .spo        (dm_dout_byte[1]),
        .dpo        (mem_check_data[15:8])
    );
    DPRAM data_mem2(
        .clk        (clk),
        .we         (dm_we & dm_we_mask[2]),
        .a          (dm_addr[9:2]),
        .d          (dm_din_byte[2 & dm_wa_mask]),
        .dpra       (mem_check_addr[9:2]),
        .spo        (dm_dout_byte[2]),
        .dpo        (mem_check_data[23:16])
    );
    DPRAM data_mem3(
        .clk        (clk),
        .we         (dm_we & dm_we_mask[3]),
        .a          (dm_addr[9:2]),
        .d          (dm_din_byte[3 & dm_wa_mask]),
        .dpra       (mem_check_addr[9:2]),
        .spo        (dm_dout_byte[3]),
        .dpo        (mem_check_data[31:24])
    );
endmodule