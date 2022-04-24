//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0816192
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signals
////Program Counter
wire [32-1:0] pc_in_i;
wire [32-1:0] pc_out_o;
////Adder1	 
wire [32-1:0] add1_out_o;
////Instr_Memory
wire [32-1:0] instr_o;
wire [ 6-1:0] op;
wire [ 5-1:0] ins_col2;		  
wire [ 5-1:0] ins_col3;		  
wire [ 5-1:0] ins_col4;
wire [15-1:0] ins_iform;
wire [ 6-1:0] funct;		  
////Mux_Write_Reg
wire  [5-1:0] mux_rw;
////Decoder
wire  [3-1:0] ALUOp;
wire		  ALUSrc;
wire		  Branch;
wire  [3-1:0] BranchType;
wire		  RegWrite;
wire  [2-1:0] RegDst;
wire		  MemRead;
wire		  MemWrite;
wire  [2-1:0] MemtoReg;
wire		  Jump;
////Reg_File
wire [32-1:0] RSdata_o;
wire [32-1:0] RTdata_o;
////ALU_Ctrl
wire  [4-1:0] ALUCtrl_o;
////Sign_Extend
wire [32-1:0] sign_extend_o;
////Mux_ALUSrc
wire [32-1:0] mux_alu_src;
////ALU
wire [32-1:0] ALU_result_o;
wire 		  zero_o;
////Adder2
wire [32-1:0] add2_out_o;
////Data_Memory
wire [32-1:0] data_mem_o;
////Shifter
wire [32-1:0] shift_left_o;
////Mux_Branch
/*wire [32-1:0] mux_branch;		*/
////Mux_Branch_PC
wire [32-1:0] mux_branch_pc;
wire 		  s_mux_pc_src;
////Mux_Data_Memory
wire [32-1:0] mux_dm;
////Mux_PC_Source
wire [32-1:0] mux_pc_src;
wire [32-1:0] j_addr_28;
wire [32-1:0] j_addr;
////Mux_Jump
wire [32-1:0] mux_jump;
wire 		  jr_ctrl;

//Wire connection
assign pc_in_i 		= mux_pc_src;
assign op			= instr_o[31:26];
assign ins_col2		= instr_o[25:21];
assign ins_col3		= instr_o[20:16];
assign ins_col4		= instr_o[15:11];
assign ins_iform	= instr_o[15: 0];
assign funct		= instr_o[ 5: 0];
assign s_mux_pc_src = zero_o & Branch;
assign j_addr[31:28]= add1_out_o[31:28];
assign j_addr[27: 0]= j_addr_28;
assign jr_ctrl		= (instr_o[31:26]==6'd0)&(instr_o[5:0]==6'd8);
//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i(rst_i),     
	    .pc_in_i(pc_in_i),   
	    .pc_out_o(pc_out_o) 
	    );
	
Adder Adder1(
        .src1_i(32'd4),     
	    .src2_i(pc_out_o),     
	    .sum_o(add1_out_o)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out_o),  
	    .instr_o(instr_o)    
	    );

MUX_3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .data2_i(5'd31),
        .select_i(RegDst),
        .data_o(mux_rw)
        );
		
Reg_File Registers(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(instr_o[25:21]) ,  
        .RTaddr_i(instr_o[20:16]) ,  
        .RDaddr_i(mux_rw) ,  
        .RDdata_i(mux_dm) , 
        .RegWrite_i (RegWrite),
        .RSdata_o(RSdata_o) ,  
        .RTdata_o(RTdata_o)   
        );
	
Decoder Decoder(
        .instr_op_i(instr_o[31:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALU_op_o(ALUOp),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),   
		.Branch_o(Branch),
		.Jump_o(Jump),
		.MemRead_o(MemRead),
		.MemWrite_o(MemWrite),
		.MemtoReg_o(MemtoReg)
		);

ALU_Ctrl AC(
        .funct_i(instr_o[5:0]), 
        .ALUOp_i(ALUOp),
        .ALUCtrl_o(ALUCtrl_o) 
        );
		
Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(sign_extend_o)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata_o),
        .data1_i(sign_extend_o),
        .select_i(ALUSrc),
        .data_o(mux_alu_src)
        );	

ALU ALU(
        .src1_i(RSdata_o),
	    .src2_i(mux_alu_src),
	    .ctrl_i(ALUCtrl_o),
	    .result_o(ALU_result_o),
		.zero_o(zero_o)
	    );
	
Data_Memory Data_Memory(
		.clk_i(clk_i),
		.addr_i(ALU_result_o),
		.data_i(RTdata_o),
		.MemRead_i(MemRead),
		.MemWrite_i(MemWrite),
		.data_o(data_mem_o)
		);
	
MUX_3to1 #(.size(32)) Mux_Write_Data(
        .data0_i(ALU_result_o),
        .data1_i(data_mem_o),
        .data2_i(add1_out_o),
        .select_i(MemtoReg),
        .data_o(mux_dm)
		);
		
Adder Adder2(
        .src1_i(add1_out_o),
	    .src2_i(shift_left_o),     
	    .sum_o(add2_out_o)
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(sign_extend_o),
        .data_o(shift_left_o)
        ); 
/*		
MUX_4to1 #(.size()) Mux_Branch(
        .data0_i(zero_o),
        .data1_i(~Result[31] | zero_o),
        .data2_i(~ALU_result_o[31]),
        .data3_i(~zero_o),
        .select_i(BranchType),
        .data_o(mux_branch_o)
        );	
*/
MUX_2to1 #(.size(32)) Mux_Branch_PC(
        .data0_i(add1_out_o),
        .data1_i(add2_out_o),
        .select_i(s_mux_pc_src),
        .data_o(mux_branch_pc)
        );

Shift_Left_Two_32 Jump_Address(
        .data_i(instr_o[25:0]),
        .data_o(j_addr_28)
        ); 

MUX_2to1 #(.size(32)) Mux_Jump(
        .data0_i(mux_branch_pc),
        .data1_i(j_addr),
        .select_i(Jump),
        .data_o(mux_jump)
        );	

MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(mux_jump),
        .data1_i(RSdata_o),
        .select_i(jr_ctrl),
        .data_o(mux_pc_src)
        );	


endmodule
		  


