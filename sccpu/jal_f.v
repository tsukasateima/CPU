module jal_f(jal, rw0, ctrout, rw);
input jal;
input [4:0] rw0;
output reg ctrout;
output reg [4:0] rw;
always @(*)
begin
	if(jal) begin ctrout=1; rw=5'b11111; end
	else begin ctrout=0; rw=rw0; end
end
endmodule