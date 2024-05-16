module scdatamem(WrEn,Adr,Clk,DataIn,DataOut);
input Clk;
input WrEn;
input [31:0] Adr, DataIn;//地址是32位
output [31:0] DataOut;
reg [31:0] data [31:0];
assign DataOut=data[Adr[6:2]];
always@(posedge Clk)
begin
	if(WrEn)
	data[Adr[6:2]]=DataIn;

end
integer i;
initial begin
	for (i = 0;i < 32;i = i + 1)
		data[i] = 0;
	data[5'h08] = 32'h0000_0030;
	data[5'h09] = 32'h0000_003c;
	data[5'h0a] = 32'h0000_0054;
	data[5'h0b] = 32'h0000_0068;
	data[5'h12] = 32'h0000_0002;
	data[5'h13] = 32'h7fff_ffff;
	data[5'h14] = 32'h0000_00A3;
	data[5'h15] = 32'h0000_0027;
	data[5'h16] = 32'h0000_0079;
	data[5'h17] = 32'h0000_0115;
end
endmodule