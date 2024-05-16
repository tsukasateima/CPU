module excReg(in, clk, reset, wren, out);
input [31:0] in;
input clk, wren,reset;
output [31:0]out;
reg [31:0]data;
assign out=data;
always@(posedge clk)
begin 
	if(wren)data<=in;
end
endmodule
