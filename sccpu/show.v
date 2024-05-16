module show(in,out);
input[3:0] in;
output reg[6:0] out;
always @(*)
begin
	case(in)
	0:out<='b1000000;
	1:out<='b1111001;
	2:out<='b0100100;
	3:out<='b0110000;
	4:out<='b0011001;
	5:out<='b0010010;
	6:out<='b0000010;
	7:out<='b1111000;
	8:out<='b0000000;
	9:out<='b0010000;
	10:out<='b0001000;
	11:out<='b0000011;
	12:out<='b1000110;
	13:out<='b0100001;
	14:out<='b0000110;
	15:out<='b0001110;
	default:out<='b1111111;
	endcase
end
endmodule