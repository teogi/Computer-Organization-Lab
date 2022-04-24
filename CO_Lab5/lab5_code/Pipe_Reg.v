`timescale 1ns / 1ps
//Subject:     CO project 4 - Pipe Register
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_Reg(
    clk_i,
    rst_i,
    data_i,
	valid_i,
	flush_i,
    data_o
    );
					
parameter size = 1;
parameter ctrl_size = 1;

input   clk_i;		  
input   rst_i;
input   [size-1:0] data_i;
input 	valid_i;
input 	flush_i;
output reg  [size-1:0] data_o;
	  
always@(posedge clk_i) begin
    if(~rst_i)
        data_o <= 0;
    else if(valid_i)	
        data_o <= data_i;
end

always@(posedge clk_i) begin
	if(flush_i)
		data_o[ctrl_size-1:0] <= 0;
end

endmodule	