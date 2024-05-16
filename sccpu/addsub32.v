module addsub32 (a, b, sub, s);
	input [31:0] a,b;
    input sub;
    output [31:0]s;
    cla32 as32(a, b^{32{sub}}, sub, s);//通过b与sub的位异或来决定是加法或减法,cla32本身为32位加法器
endmodule