//符号拓展器16-30
//根据flag 1是符号拓展
//根据flag 0是零拓展
//其他为异常情况
module extendedThirty(in,out,flag);
input [15:0]in;
output reg [29:0]out;
input flag;
always@(*)
begin
	case(flag)
	1'b1:if(in[15]==1)out={{14{1'b1}},in};
			else out={{14{1'b0}},in};
	1'b0:out = {{14{1'b0}},in};
	endcase 
end
endmodule