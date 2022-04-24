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
module HazardUnit(
	IF_ID_RegisterRs_i,
	IF_ID_RegisterRt_i,
	ID_EX_MemRead_i,
	ID_EX_RegisterRs_i,
	ID_EX_RegisterRt_i,
	Branch_i,
	PCWrite_o,
	IF_IDWrite_o,
	Control_o,
	Flush_o
);

// I/O ports
input [5-1:0] IF_ID_RegisterRs_i;
input [5-1:0] IF_ID_RegisterRt_i;
input 		  ID_EX_MemRead_i;
input		  Branch_i;
input [5-1:0] ID_EX_RegisterRs_i;
input [5-1:0] ID_EX_RegisterRt_i;

output		  PCWrite_o;
output		  IF_IDWrite_o;
output        Control_o;
output        Flush_o;


//internal signals/registers
reg		  	  PCWrite_o;
reg		  	  IF_IDWrite_o;
reg		  	  Control_o;
reg		  	  Flush_o;


//forward to input A of ALU if conditions satified
always @(*)begin
	if(ID_EX_MemRead_i &((ID_EX_RegisterRt_i == IF_ID_RegisterRs_i)|
	   (ID_EX_RegisterRt_i==IF_ID_RegisterRt_i)))
	begin
		PCWrite_o <= 0;
		IF_IDWrite_o <= 0;
		Control_o <= 0;
	end
	else begin
		PCWrite_o <= 1;
		IF_IDWrite_o <= 1;
		Control_o <= 1;
	end
end

always @(*)begin
	if(Branch_i)
		Flush_o <= 1;
	else
		Flush_o <= 0;
end

endmodule