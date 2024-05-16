module toLowclk(iclk,oclk);
input iclk;
output reg oclk;
reg [26:0]num;
always@(posedge iclk)
begin
	num=(num+1)%50000000;
	if(num==1)
	begin
		oclk<=~oclk;
	end
end
endmodule