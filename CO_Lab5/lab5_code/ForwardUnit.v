`timescale 1ns / 1ps
//Subject:     CO project 5 - Forward Unit
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module ForwardUnit(
	ID_EX_RegisterRs_i,
	ID_EX_RegisterRt_i,
	EX_MEM_RegWrite_i,
	EX_MEM_RegisterRd_i,
	MEM_WB_RegWrite_i,
    MEM_WB_RegisterRd_i,
	ForwardA_o,
	ForwardB_o
);

// I/O ports
input [5-1:0] ID_EX_RegisterRs_i;
input [5-1:0] ID_EX_RegisterRt_i;
input 		  EX_MEM_RegWrite_i;
input [5-1:0] EX_MEM_RegisterRd_i;
input 		  MEM_WB_RegWrite_i;
input [5-1:0] MEM_WB_RegisterRd_i;

output [2-1:0] ForwardA_o;
output [2-1:0] ForwardB_o;

//internal signals/registers
reg [2-1:0] ForwardA_o;
reg [2-1:0] ForwardB_o;

//forward to input A of ALU if conditions satified
always @(*) begin
	//EX hazard
	if ((EX_MEM_RegWrite_i & (EX_MEM_RegisterRd_i !=0)
	   & (EX_MEM_RegisterRd_i == ID_EX_RegisterRs_i)))
		ForwardA_o <= 2'b10;
	//MEM hazard
	else if(MEM_WB_RegWrite_i & (MEM_WB_RegisterRd_i !=0)
		& !(EX_MEM_RegWrite_i & (EX_MEM_RegisterRd_i !=0)
		   & (EX_MEM_RegisterRd_i == ID_EX_RegisterRs_i))
		& (MEM_WB_RegisterRd_i == ID_EX_RegisterRs_i))
		ForwardA_o <=2'b01;
	else
		ForwardA_o <= 2'b00;
	
	//EX hazard
	if( EX_MEM_RegWrite_i & (EX_MEM_RegisterRd_i !=0)
	   & (EX_MEM_RegisterRd_i == ID_EX_RegisterRt_i))
		ForwardB_o <= 2'b10;
	//MEM hazard
	else if(MEM_WB_RegWrite_i & (MEM_WB_RegisterRd_i !=0)
	   & !(EX_MEM_RegWrite_i & (EX_MEM_RegisterRd_i !=0)
		   & (EX_MEM_RegisterRd_i == ID_EX_RegisterRt_i))
	   & (MEM_WB_RegisterRd_i == ID_EX_RegisterRt_i))
		ForwardB_o <= 2'b01;
	else
		ForwardB_o <= 2'b00;
	
end

endmodule