//Subject:     CO project 3 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke,0816192
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [5-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [5-1:0] ALUCtrl_o;

//Parameter

       
//Select exact operation
always @(*)begin
	case(ALUOp_i)
		0: ALUCtrl_o <= 2; //lw or sw
		1: ALUCtrl_o <= 6; //beq
		2://R-type
			case(funct_i)
				 8: ALUCtrl_o <= 5'b11111; //Jump register(no to do anything)
				24: ALUCtrl_o <= 16; //Multiplication
				32: ALUCtrl_o <= 2; //Addition
				34:	ALUCtrl_o <= 6; //Subtraction
				36:	ALUCtrl_o <= 0; //And
				37:	ALUCtrl_o <= 1; //Or
				42:	ALUCtrl_o <= 7; //Set on Less than
				default:ALUCtrl_o <= 5'b11111;
			endcase
		3: ALUCtrl_o <= 2;	//addi
		4: ALUCtrl_o <= 7;	//slti
		default: ALUCtrl_o <= 5'b11111;
	endcase
end
endmodule     





                    
                    