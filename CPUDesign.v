/*
该程序为主程序，通过调用各种模块实现功能
该模块的输入输出都与CPU本身无关，为拓展功能
*/
module CPUDesign(clk,reset,intr);
//定义变量
(*chip_pin="AF14"*)input clk;
(*chip_pin="AA14"*)input reset;
(*chip_pin="AB12"*)input intr;
wire [31:0]npc;//pc重置后的值

//中间变量
wire wren;
wire [31:0] addr;
wire [31:0] dataIn, dataOut;
wire [31:0] pcnext;
wire [31:0] pc, ins;//pc和指令
wire lowclk;

//调用分频器
 pll_pll pll_cpu_inst(
		/*input  wire  */    .refclk(clk),   
		/*input  wire  */    .rst(1'b0),      
		/*output wire  */    .outclk_0(lowclk),
		.locked   ()
	);

//对pc重置归零
resetPC(.pc(pc),.clk(lowclk),.reset(reset), .pcnext(pcnext));

//调用指令写入模块
scinstmem sci(.a(pc),.inst(ins));

//调用数据通路模块
main_dataflow(.pc(pc), .inst(ins), .memout(dataOut), .pcnext(pcnext),.clk(lowclk),.wren(wren),.intr(intr),.addr(addr));

//调用数据存储器
scdatamem dmem(.WrEn(wren) , .Adr(addr), .Clk(lowclk), .DataIn(dataIn), .DataOut(dataOut));

endmodule