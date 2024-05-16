module cs_generator(z,inst,RegWr,RegDst,jal,MemtoReg,shift,AluSrc,Extop,WrEn,pcsrc,AluCtr,
ov,mfc0, mtc0, wsta, wcau, wepc, exc,intr,inta,selpc,sta,cause);
  input  [31:0] inst;
  
  input  [31:0] sta;                                    // c0 status
  input         z, ov;                                   // z, ov flags
  input         intr;                                   // interrupt request
  output [31:0] cause;                                  // c0 cause
  output  [3:0] AluCtr;                                   // alu control
  output  [1:0] mfc0;                                   // move from c0 regs
  output  [1:0] selpc;                                  // select for pc
  output  [1:0] pcsrc;                                  // select pc source
  output        RegWr,RegDst,jal,MemtoReg,shift,AluSrc,Extop,WrEn;
  output        inta;                                   // interrupt ack
  output        exc;                                    // exc or int occurs
  output        wsta;                                   // write status reg
  output        wcau;                                   // write cause reg
  output        wepc;                                   // move to c0 regs
  output        mtc0;                                   // move to c0 regs
  wire    [5:0] op   = inst[31:26];             // op
  wire    [4:0] rd   = inst[15:11];             // rd
  wire    [5:0] func = inst[5:0];             // func
  wire    [4:0] op1   = inst[25:21];             // rs
  wire rtype  = ~|op;                                            // r format
  wire i_add  = rtype& func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
  wire i_sub  = rtype& func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0];
  wire i_and  = rtype& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
  wire i_or   = rtype& func[5]&~func[4]&~func[3]& func[2]&~func[1]& func[0];
  wire i_xor  = rtype& func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0];
  wire i_sll  = rtype&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
  wire i_srl  = rtype&~func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0];
  wire i_sra  = rtype&~func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
  wire i_jr   = rtype&~func[5]&~func[4]& func[3]&~func[2]&~func[1]&~func[0];
  wire i_addi = ~op[5] &~op[4] & op[3] &~op[2] &~op[1] &~op[0];  // i format
  wire i_andi = ~op[5] &~op[4] & op[3] & op[2] &~op[1] &~op[0];
  wire i_ori  = ~op[5] &~op[4] & op[3] & op[2] &~op[1] & op[0];
  wire i_xori = ~op[5] &~op[4] & op[3] & op[2] & op[1] &~op[0];
  wire i_lw   =  op[5] &~op[4] &~op[3] &~op[2] & op[1] & op[0];
  wire i_sw   =  op[5] &~op[4] & op[3] &~op[2] & op[1] & op[0];
  wire i_beq  = ~op[5] &~op[4] &~op[3] & op[2] &~op[1] &~op[0];
  wire i_bne  = ~op[5] &~op[4] &~op[3] & op[2] &~op[1] & op[0];
  wire i_lui  = ~op[5] &~op[4] & op[3] & op[2] & op[1] & op[0];
  wire i_j    = ~op[5] &~op[4] &~op[3] &~op[2] & op[1] &~op[0];  // j format
  wire i_jal  = ~op[5] &~op[4] &~op[3] &~op[2] & op[1] & op[0];
  wire c0type = ~op[5] & op[4] &~op[3] &~op[2] &~op[1] &~op[0];
  wire i_mfc0 = c0type &~op1[4] &~op1[3] &~op1[2] &~op1[1] &~op1[0];
  wire i_mtc0 = c0type &~op1[4] &~op1[3] & op1[2] &~op1[1] &~op1[0];
  wire i_eret = c0type & op1[4] &~op1[3] &~op1[2] &~op1[1] &~op1[0] &
                ~func[5] & func[4] & func[3] &~func[2] &~func[1] &~func[0];
  wire i_syscall = rtype &
                ~func[5] &~func[4] & func[3] & func[2] &~func[1] &~func[0];
  wire unimplemented_inst = ~(i_mfc0 | i_mtc0 | i_eret | i_syscall |
       i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra |
       i_jr | i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_beq |
       i_bne| i_lui| i_j| i_jal);
  wire rd_is_status = (rd == 5'd12);                    // is cp0 status reg
  wire rd_is_cause  = (rd == 5'd13);                    // is cp0 cause reg
  wire rd_is_epc    = (rd == 5'd14);                    // is cp0 epc reg
  wire overflow = ov & (i_add | i_sub | i_addi);         // overflow
  wire int_int  = sta[0] & intr;                        // sta[0]: enable
  wire exc_sys  = sta[1] & i_syscall;                   // sta[1]: enable
  wire exc_uni  = sta[2] & unimplemented_inst;          // sta[2]: enable
  wire exc_ovr  = sta[3] & overflow;                    // sta[3]: enable
  assign inta   = int_int;                              // interrupt ack
  // exccode: 0 0 : intr                                // generate exccode
  //          0 1 : i_syscall
  //          1 0 : unimplemented_inst
  //          1 1 : overflow
  wire exccode0 = i_syscall | overflow;
  wire exccode1 = unimplemented_inst | overflow;
  // mfc0:    0 0 : alu_mem                             // generate mux sel
  //          0 1 : sta
  //          1 0 : cau
  //          1 1 : epc
  assign mfc0[0] = i_mfc0 & rd_is_status | i_mfc0 & rd_is_epc;
  assign mfc0[1] = i_mfc0 & rd_is_cause  | i_mfc0 & rd_is_epc;
  // selpc:   0 0 : npc                                 // generate mux sel
  //          0 1 : epc
  //          1 0 : exc_base
  //          1 1 : x
  assign selpc[0] = i_eret;
  assign selpc[1] = exc;
  assign cause = {28'h0,exccode1,exccode0,2'b00};       // cause
  assign exc   = int_int | exc_sys | exc_uni | exc_ovr; // exc or int occurs
  assign mtc0  = i_mtc0;                                // highest priority
  assign wsta  = exc | mtc0 & rd_is_status | i_eret;    // write status reg
  assign wcau  = exc | mtc0 & rd_is_cause;              // write cause reg
  assign wepc  = exc | mtc0 & rd_is_epc;                // write epc reg
  assign RegDst    = i_addi| i_andi| i_ori| i_xori| i_lw | i_lui| i_mfc0;
  assign jal      = i_jal;
  assign MemtoReg    = i_lw;
  assign WrEn     = i_sw;
  assign AluCtr[3]  = i_sra;                              // refer to alu_ov.v
  assign AluCtr[2]  = i_sub| i_or| i_srl| i_sra| i_ori| i_lui;
  assign AluCtr[1]  = i_xor| i_sll| i_srl| i_sra| i_xori| i_beq| i_bne| i_lui;
  assign AluCtr[0]  = i_and| i_or| i_sll| i_srl| i_sra| i_andi| i_ori;
  assign shift    = i_sll | i_srl | i_sra;
  assign AluSrc   = i_addi| i_andi| i_ori| i_xori| i_lw | i_lui| i_sw;
  assign Extop     = i_addi| i_lw  | i_sw | i_beq | i_bne;
  assign pcsrc[1] = i_jr  | i_j   | i_jal;
  assign pcsrc[0] = i_beq & z | i_bne & ~z | i_j | i_jal;
  assign RegWr = i_add | i_sub | i_and| i_or  | i_xor| i_sll| i_srl| i_sra|
                i_addi| i_andi| i_ori| i_xori| i_lw | i_lui| i_jal| i_mfc0;
endmodule

