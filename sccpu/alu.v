module alu(a_,b_,aluc_,r,z,v);
	output wire v;
	input [31:0] a_,b_;
	input [3:0] aluc_;
	output [31:0] r;
	output z;
	wire [31:0] d_and=a_&b_;
	wire [31:0] d_or=a_|b_;
	wire [31:0] d_xor=a_^b_;
	wire [31:0] d_lui={b_[15:0],16'h0};
	wire [31:0] d_and_or=aluc_[2]?d_or:d_and;
	wire [31:0] d_xor_lui=aluc_[2]?d_lui:d_xor;
	wire [31:0] d_as/*synthesis keep*/;
	wire [31:0] d_sh/*synthesis keep*/;
	assign v = ~aluc_[2] & ~a_[31] & ~b_[31] & r[31] & ~aluc_[1] & ~aluc_[0] |
           ~aluc_[2] &  a_[31] &  b_[31] &~r[31] & ~aluc_[1] & ~aluc_[0] |
			   aluc_[2] & ~a_[31] &  b_[31] & r[31] & ~aluc_[1] & ~aluc_[0] |
            aluc_[2] &  a_[31] & ~b_[31] &~r[31] & ~aluc_[1] & ~aluc_[0] ;
	addsub32 as32(a_,b_,aluc_[2],d_as);
	shift shifter(b_,a_[4:0],aluc_[2],aluc_[3],d_sh);
	mux4x32 select(d_as,d_and_or,d_xor_lui,d_sh,aluc_[1:0],r);
	assign z=~|r;
endmodule