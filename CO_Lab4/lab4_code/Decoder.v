//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke,0816192
//----------------------------------------------
//Date:        2010/8/16
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
	);
     
//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output [2-1:0] RegDst_o;
output         Branch_o;
output 		   Jump_o;
output		   MemRead_o;
output		   MemWrite_o;
output [2-1:0] MemtoReg_o;
 
//Internal Signals
reg    [3-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg	   [2-1:0] RegDst_o;
reg            Branch_o;
reg 		   Jump_o;
reg			   MemRead_o;
reg			   MemWrite_o;
reg	   [2-1:0] MemtoReg_o;

wire		   Rformat_ctrl ;//including jr
wire		   lw_ctrl		;
wire		   sw_ctrl		;
wire		   beq_ctrl		;
wire		   bne_ctrl		;
wire		   bge_ctrl		;
wire		   bgt_ctrl		;
wire		   addi_ctrl	;
wire		   slti_ctrl	;
wire		   j_ctrl		;
wire		   jal_ctrl		;
//Parameter
//Main function
////R-format
assign Rformat_ctrl = &(~instr_op_i);
////I-format
assign lw_ctrl		= (instr_op_i== 6'b100011);
assign sw_ctrl		= (instr_op_i== 6'b101011);
assign beq_ctrl		= (instr_op_i== 6'd4);
assign bne_ctrl		= (instr_op_i== 6'd5);
assign bge_ctrl		= (instr_op_i== 6'd1);
assign bgt_ctrl		= (instr_op_i== 6'd7);
assign addi_ctrl	= (instr_op_i== 6'd8);
assign slti_ctrl	= (instr_op_i==6'd10);
////J-format
assign j_ctrl		= (instr_op_i== 6'd2);
assign jal_ctrl		= (instr_op_i== 6'd3);

always @(instr_op_i)begin
	if(lw_ctrl | sw_ctrl)
		ALU_op_o <= 3'd0; //0 if it is lw or sw
	else if(beq_ctrl| bne_ctrl | bge_ctrl | bgt_ctrl)
		ALU_op_o <= 3'd1; //1 if it is beq
	else if(Rformat_ctrl)
		ALU_op_o <= 3'd2; //2 if it is R-format
	else if(addi_ctrl)
		ALU_op_o <= 3'd3; //3 if it is addi
	else if(slti_ctrl)
		ALU_op_o <= 3'd4; //4 if it is slti
	else
		ALU_op_o <= 3'b111;
end

always @(instr_op_i)begin
	ALUSrc_o <= addi_ctrl | slti_ctrl | lw_ctrl | sw_ctrl;
end

always @(instr_op_i)begin
	RegWrite_o <= Rformat_ctrl | addi_ctrl | slti_ctrl | lw_ctrl | jal_ctrl;
end

always @(instr_op_i)begin
	RegDst_o <= Rformat_ctrl;
	//RegDst_o <= Rformat_ctrl ? 1:(jal_ctrl ? 2 : 0);
end

always @(instr_op_i)begin
	MemRead_o <= lw_ctrl;
end

always @(instr_op_i)begin
	MemWrite_o <= sw_ctrl;
end

always @(instr_op_i)begin
	if(lw_ctrl)
		MemtoReg_o <= 1;
	else if(jal_ctrl)
		MemtoReg_o <= 2;
	else
		MemtoReg_o <= 0;
	//MemtoReg_o <= lw_ctrl? 1:(jal_ctrl ? 2 : 0);
end

always @(instr_op_i)begin
	Branch_o <= beq_ctrl;
end



always @(instr_op_i)begin
	Jump_o <= j_ctrl | jal_ctrl;
end

endmodule





                    
                    