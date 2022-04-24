`timescale 1ns / 1ps
//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
    clk_i,
    rst_i
    );
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
/**** IF stage ****/
wire [32-1:0] IF_pc_add4;
wire [32-1:0] IF_branch_result;
wire [32-1:0] IF_pc_in;
wire 		  IF_PCSrc;
wire [32-1:0] IF_pc_out;
wire [32-1:0] IF_instr;

/**** ID stage ****/
wire [32-1:0] ID_pc_add4;
wire [32-1:0] ID_instr;
wire [32-1:0] ID_RSdata;
wire [32-1:0] ID_RTdata;
wire [ 5-1:0] ID_instr2;
wire [ 5-1:0] ID_instr3;
wire [32-1:0] ID_extend_out;
//control signal
wire [ 3-1:0] ID_ALU_op_EX;
wire 		  ID_ALUSrc_EX;
wire 		  ID_RegDst_EX;
wire 		  ID_Branch_MEM;
wire 		  ID_MemRead_MEM;
wire 		  ID_MemWrite_MEM;
wire 		  ID_RegWrite_WB;
wire 		  ID_MemtoReg_WB;

/**** EX stage ****/
wire [32-1:0] EX_pc_add4;
wire [32-1:0] EX_RSdata;
wire [32-1:0] EX_RTdata;
wire [32-1:0] EX_extend_out;
wire [32-1:0] EX_shift_left;
wire [32-1:0] EX_pc_branch;
wire [32-1:0] EX_ALU_2nd;
wire [32-1:0] EX_ALU_result;
wire [ 5-1:0] EX_ALU_ctrl;
wire		  EX_zero;
wire [ 5-1:0] EX_instr2;
wire [ 5-1:0] EX_instr3;
wire [ 5-1:0] EX_RDaddr;
//control signal
wire [ 3-1:0] EX_ALU_op;
wire 		  EX_ALUSrc;
wire 		  EX_RegDst;
wire 		  EX_Branch_MEM;
wire 		  EX_MemRead_MEM;
wire 		  EX_MemWrite_MEM;
wire 		  EX_RegWrite_WB;
wire 		  EX_MemtoReg_WB;

/**** MEM stage ****/
wire [32-1:0] MEM_pc_branch;
wire 		  MEM_zero;
wire [32-1:0] MEM_ALU_result;
wire [32-1:0] MEM_RTdata;
wire [32-1:0] MEM_dm_out;
wire [ 5-1:0] MEM_RDaddr;
//control signal
wire 		  MEM_Branch;
wire 		  MEM_MemRead;
wire 		  MEM_MemWrite;
wire 		  MEM_RegWrite_WB;
wire 		  MEM_MemtoReg_WB;

/**** WB stage ****/
wire [32-1:0] WB_ALU_result;
wire [32-1:0] WB_dm_out;
wire [32-1:0] WB_RDdata;
wire [ 5-1:0] WB_RDaddr;
//control signal
wire 		  WB_RegWrite;
wire 		  WB_MemtoReg;


/****************************************
Instantiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux0(
	.data0_i(IF_pc_add4),
	.data1_i(IF_branch_result),
	.select(IF_PCSrc),
	.data_o(IF_pc_in)
);

ProgramCounter PC(
    .clk_i(clk_i),      
	.rst_i(rst_i), 
	.pc_in_i(IF_pc_in),
	.pc_out_o(IF_pc_out)
);

Instruction_Memory IM(
	.addr_i(IF_pc_out),
	.instr_o(IF_instr)
);
			
Adder Add_pc(
	.src1_i(32'd4),
	.src2_i(IF_pc_out),
	.sum_o(IF_pc_add4)  
);

		
Pipe_Reg #(.size(64)) IF_ID(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i({IF_pc_add4,IF_instr}),
	.data_o({ID_pc_add4,ID_instr})
);


//Instantiate the components in ID stage
Reg_File RF(
	.clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(ID_instr[25:21]),
    .RTaddr_i(ID_instr[20:16]),
    .RDaddr_i(WB_RDaddr),
    .RDdata_i(WB_RDdata),
    .RegWrite_i(WB_RegWrite),
    .RSdata_o(ID_RSdata),
    .RTdata_o(ID_RTdata)
);

Decoder Control(
	.instr_op_i(ID_instr[31:26]),
	.RegWrite_o(ID_RegWrite_WB),
	.ALU_op_o(ID_ALU_op_EX),
	.ALUSrc_o(ID_ALUSrc_EX),
	.RegDst_o(ID_RegDst_EX),
	.Branch_o(ID_Branch_MEM),
	.MemRead_o(ID_MemRead_MEM),
	.MemWrite_o(ID_MemWrite_MEM),
	.MemtoReg_o(ID_MemtoReg_WB)
);

Sign_Extend Sign_Extend(
	.data_i(ID_instr[15:0]),
	.data_o(ID_extend_out)
);	

Pipe_Reg #(.size(128+10+10)) ID_EX(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.data_i({ID_pc_add4,
			 ID_RSdata,
			 ID_RTdata,
			 ID_extend_out,
			 ID_instr2,
			 ID_instr3,
			 ID_ALU_op_EX,
			 ID_ALUSrc_EX,
			 ID_RegDst_EX,
			 ID_Branch_MEM,
			 ID_MemRead_MEM,
			 ID_MemWrite_MEM,
			 ID_RegWrite_WB,
			 ID_MemtoReg_WB
			 }),
	.data_o({EX_pc_add4,
			 EX_RSdata,
			 EX_RTdata,
			 EX_extend_out,
			 EX_instr2,
			 EX_instr3,
			 EX_ALU_op,
			 EX_ALUSrc,
			 EX_RegDst,
			 EX_Branch_MEM,
			 EX_MemRead_MEM,
			 EX_MemWrite_MEM,
			 EX_RegWrite_WB,
			 EX_MemtoReg_WB
			 })
);


//Instantiate the components in EX stage	   
Shift_Left_Two_32 Shifter(
	.data_i(EX_extend_out),
	.data_o(EX_shift_left)
);	

ALU ALU(
    .src1_i(EX_RSdata),
	.src2_i(EX_ALU_2nd),
	.ctrl_i(EX_ALU_ctrl),
	.result_o(EX_ALU_result),
	.zero_o(EX_zero)
);
		
ALU_Ctrl ALU_Control(
	.funct_i(EX_extend_out[5:0]),
    .ALUOp_i(EX_ALU_op),
    .ALUCtrl_o(EX_ALU_ctrl)
);

MUX_2to1 #(.size(32)) Mux1(
	.data0_i(EX_RTdata),
	.data1_i(EX_extend_out),
	.select(EX_ALUSrc),
	.data_o(EX_ALU_2nd)
);

MUX_2to1 #(.size(5)) Mux2(
	.data0_i(EX_instr2),
	.data1_i(EX_instr3),
	.select(EX_RegDst),
	.data_o(EX_RDaddr)
);

Adder Add_pc_branch(
	.src1_i(EX_pc_add4),
	.src2_i(EX_shift_left),
	.sum_o(EX_pc_branch)
);

Pipe_Reg #(.size(97+5+5)) EX_MEM(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.data_i({EX_pc_branch,
			 EX_zero,
			 EX_ALU_result,
			 EX_RTdata,
			 EX_RDaddr,
			 EX_Branch_MEM,
			 EX_MemRead_MEM,
			 EX_MemWrite_MEM,
			 EX_RegWrite_WB,
			 EX_MemtoReg_WB
			}),
	.data_o({MEM_pc_branch,
			 MEM_zero,
             MEM_ALU_result,
             MEM_RTdata,
			 MEM_RDaddr,
			 MEM_Branch,
			 MEM_MemRead,
			 MEM_MemWrite,
			 MEM_RegWrite_WB,
			 MEM_MemtoReg_WB
			 })
);
//Instantiate the components in MEM stage
Data_Memory DM(
	.clk_i(clk_i),
    .addr_i(MEM_ALU_result),
    .data_i(MEM_RTdata),
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),
    .data_o(MEM_dm_out)
);

Pipe_Reg #(.size(64+5+2)) MEM_WB(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.data_i({MEM_ALU_result,
			 MEM_dm_out,
			 MEM_RDaddr,
			 MEM_RegWrite_WB,
			 MEM_MemtoReg_WB
			}),
	.data_o({WB_ALU_result,
			 WB_dm_out,
			 WB_RDaddr,
			 WB_RegWrite,
			 WB_MemtoReg
			})
);


//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux3(
	.data0_i(WB_ALU_result),
	.data1_i(WB_dm_out),
	.select(WB_MemtoReg),
	.data_o(WB_RDdata)
);

/****************************************
signal assignment
****************************************/
assign IF_PCSrc = MEM_Branch & MEM_zero;
assign IF_branch_result = EX_pc_branch;
assign ID_instr2 = ID_instr[20:16];
assign ID_instr3 = ID_instr[15:11];

endmodule

