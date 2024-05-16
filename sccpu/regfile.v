/*
该模块为寄存器组
输入有 rf_clk(时钟), rw ra rb(5位 选择寄存器地址); busW(32位 写入寄存器内容); RegWr(1位 写使能)
输出有 busA busB(32位 输出寄存器内容)
*/
module regfile(rf_clk, rw, ra, rb, busW, RegWr, busA, busB,reset);
input [4:0] rw, ra, rb;
input [31:0] busW;
input RegWr, rf_clk,reset;
output [31:0] busA, busB;
reg [31:0] registers [0:31];
always @(posedge rf_clk)
begin
	if(RegWr)	//写入寄存器
		begin
			registers[rw] = busW;
		end
end
assign busA = registers[ra];
assign busB = registers[rb];
endmodule