/*
该模块为32位2选1选择器
输入有 in0, in1(32位 待选数据); ctr(1位 选择信号)
输出有 out(32位 选择的数据)
*/
module mux2x32(in0, in1, ctr, out);
input [31:0] in1, in0;
input ctr;
output [31:0] out;
assign out = ctr?in1:in0;
endmodule