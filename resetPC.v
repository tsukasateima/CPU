module resetPC(pc,clk,reset,pcnext);
output reg [31:0] pc;
input [31:0] pcnext;
input clk,reset;
always@(negedge reset or posedge clk)
begin
	if(reset==0)pc<=32'b0;
   else pc<=pcnext;
end
endmodule