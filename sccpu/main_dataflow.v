/*
该模块为主数据通路，通过调用各种模块来实现各种功能
*/
module main_dataflow(pc, inst, memout, pcnext,clk,reset,wren, intr,addr);
//定义变量
input wire intr;
input wire [31:0] pc;
input wire [31:0] inst;
input wire [31:0] memout;
input wire clk;
input reset;
output wire [31:0] pcnext;
output wire wren;
output [31:0]addr;

assign addr=aluR;
//R型指令
wire [4:0] Rs = inst[25:21];
wire [4:0] Rt = inst[20:16];
wire [4:0] rRd = inst[15:11];
wire [4:0] rSa = inst[10:6];
assign  Rs = inst[25:21];
assign  Rt = inst[20:16];
assign  rRd = inst[15:11];
assign  rSa = inst[10:6];

//I型指令
wire [15:0] imm16;
assign imm16 = inst[15:0];

//J型指令
//wire jaddr;
//assign jaddr = inst[25:0];
//控制信号
wire RegWr,RegDst,jal,MemtoReg,shift,AluSrc,Extop,WrEn;
wire [1:0]pcsrc;
wire [3:0]AluCtr;	
assign wren=WrEn;

//异常控制信号
wire [1:0]mfc0;//选择存入通用寄存器的内容信号 0-正常数据 1-status 2-cause 3-EPC
wire mtc0;//选择存入中断寄存器的内容信号 0-中断数据 1-通用寄存器数据
wire wsta, wcau, wepc;//中断寄存器写实能信号
wire exc;//开/关中断标志
wire inta;//中断确认信号
wire [1:0]selpc;//异常pc选择信号
wire [31:0]cause;//异常信息


//中间变量
wire [31:0] aluA,aluB;//ALU AB端口输入
wire [4:0] tRw;//Rw中间值
wire [31:0] busA, busB, busW,busW0;
wire [31:0] imm32;
wire [31:0] aluR;
wire z,of;
wire addco;
wire [31:0] pc4;
wire [29:0] imm30;
wire [31:0] pcbranch;
wire [31:0] pcjump;
wire [31:0] Rw;
wire [31:0] npc;

//调用控制信号产生器
cs_generator cs_generator(z,inst,RegWr,RegDst,jal,MemtoReg,shift,AluSrc,Extop,WrEn,pcsrc,AluCtr,
of,mfc0, mtc0, wsta, wcau, wepc, exc,0,inta,selpc,sta,cause);

//对中间变量赋值

//调用选择Rw的5位2选1选择器
mux2x5 mux0(.in0(rRd), .in1(Rt), .ctr(RegDst), .out(tRw));

//调用寄存器组
regfile rf(.rf_clk(clk), .rw(Rw), .ra(Rs), .rb(Rt), .busW(busW), .RegWr(RegWr), .busA(busA), .busB(busB));
//调用ALU
alu alu0(.a_(aluA),.b_(aluB),.aluc_(AluCtr),.r(aluR),.z(z),.v(of));

//调用选择器（ALUa端口）
mux2x32 mux1(.in0(busA), .in1(rSa), .ctr(shift), .out(aluA));

//调用选择器(ALUb端口)
mux2x32 mux2(.in0(busB), .in1(imm32), .ctr(AluSrc), .out(aluB));

//调用立即数扩位器
extendedThirtyTwo extend(.in(imm16), .out(imm32), .flag(Extop));
extendedThirty extend0(.in(imm16), .out(imm30), .flag(Extop));

//产生下址pc
cla32 pcadder0(.a(pc), .b('d4), .ci(0), .s(pc4), .co(addco));
cla32 pcadder1(.a(pc4), .b({imm30,2'b00}), .ci(0), .s(pcbranch), .co(addco));
assign pcjump = {pc4[31:28], inst[25:0], 2'b00};

//写回寄存器选择器
mux2x32 mux3(.in0(aluR), .in1(memout), .ctr(MemtoReg), .out(busW0));

//下址pc选择器
mux4x32 mux4(.a0(pc4) ,.a1(pcbranch), .a2(busA), .a3(pcjump), .s(pcsrc), .y(npc));

//jal存储返回地址
jal_f jalf(.jal(jal), .rw0(tRw), .ctrout(ctrout), .rw(Rw));
mux2x32 mux5(.in0(busW1), .in1(pc4), .ctr(ctrout), .out(busW));

/////////////////////////////////////////异常处理////////////////////////////////////////////////////

//定义变量
wire [31:0]stamux2out, stain, cauin, epcin, epcmux1out;
wire [31:0] sta, cau, epc;
wire [31:0] busW1;

excReg STATUS(.in(stain), .clk(clk), .reset(reset), .wren(wsta), .out(sta));
excReg CAUSE(.in(cauin), .clk(clk), .reset(reset), .wren(wcau), .out(cau));
excReg EPC(.in(epcin), .clk(clk), .reset(reset), .wren(wepc), .out(epc));

mux2x32 stamux1(stamux2out, busB, mtc0, stain);
mux2x32 stamux2({4'h0, sta[31:4]}, {sta[27:0], 4'h0}, exc, stamux2out);
mux2x32 caumux1(cause, busB, mtc0, cauin);
mux2x32 epcmux1(pc, pcnext, inta, epcmux1out);
mux2x32 epcmux2(epcmux1out, busB, mtc0, epcin);
mux4x32 regdataselect(busW0, sta, cau, epc, mfc0, busW1);
mux4x32 pcselect(npc, epc, 32'h00000008, 'b0, selpc, pcnext);

endmodule