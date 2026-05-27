`timescale 1ns / 1ps

module top(clk, reset);
    input clk, reset;
    
    // Fios que levam os dados de 32 bits de um bloco pro outro (Barramentos)
    wire [31:0] pc_top, instruction_top, rd1_top, rd2_top, immExt_top, mux1_top, sum_out_top, nextPC_top, PCin_top, address_top, memData_top, writeBack_top;
    
    // Flags e linhas de controle que ativam ou desativam as paradas nos blocos
    wire regWrite_top, ALUSrc_top, zero_top, branch_top, select2_top, memToReg_top, memWrite_top, memRead_top;
    wire [1:0] ALUop_top; 
    wire [3:0] control_top;

    // Fetch 
    program_counter pc(.clk(clk), .reset(reset), .pc_in(PCin_top), .pc_out(pc_top));
    
    // Somador que anda o PC de 4 em 4 bytes ir pra próxima instrução
    PCplus4 pc_adder(.fromPC(pc_top), .nextPC(nextPC_top));

    // Vai lá na Instruction Memory e pega o código binário da instrução atual
    instruction_mem Inst_mem(.clk(clk), .reset(reset), .read_address(pc_top), .instruction_out(instruction_top));

    // Decode
    // Banco de registradores: lê da instrução (rs1, rs2) e se regWrite = 1, salva o resultado em rd
    reg_file registerFile(.clk(clk), .reset(reset), .regWrite(regWrite_top), .rs1(instruction_top[19:15]), .rs2(instruction_top[24:20]), .rd(instruction_top[11:7]), .writeData(writeBack_top), .read_data1(rd1_top), .read_data2(rd2_top));
    
    // Estende o sinal pra virar um número de 32 bits (Imediato)
    immConfig immConfig(.opcode(instruction_top[6:0]), .instruction(instruction_top), .immExt(immExt_top));

    // Control
    unidadeControle unidadeControle(.instruction(instruction_top[6:0]), .branch(branch_top), .memRead(memRead_top), .memToReg(memToReg_top), .ALUop(ALUop_top), .memWrite(memWrite_top), .ALUSrc(ALUSrc_top), .regWrite(regWrite_top));

    // Decide qual operação vai fazer a ALU Control
    ALU_Control ALU_Control(.ALUop(ALUop_top), .funct7(instruction_top[30]), .funct3(instruction_top[14:12]), .control_out(control_top));

    // Roda a ALU
    ALU ALU(.A(rd1_top), .B(mux1_top), .control_in(control_top), .ALU_result(address_top), .zero(zero_top));

    // Mux da ALU para escolher se o segundo vai ser o registrador ou imediato
    mux1 ALU_mux(.select1(ALUSrc_top), .a1(rd2_top), .b1(immExt_top), .mux1_out(mux1_top));

    // ADD do BRANCH
    adder adder(.in_1(pc_top), .in_2(immExt_top), .sum_out(sum_out_top));

    // AND do BRANCH com o ZERO da ALU
    AND_logic AND_logic(.branch(branch_top), .zero(zero_top), .and_out(select2_top));
    
    // Mux do PC para definir se o PC vai pro próximo que é (PC+4) ou se pula pro endereço do BRANCH
    mux2 adder_mux(.select2(select2_top), .a2(nextPC_top), .b2(sum_out_top), .mux2_out(PCin_top));


    // Memoria usada no LOAD ou STORE
    data_memory data_mem(.clk(clk), .reset(reset), .memWrite(memWrite_top), .memRead(memRead_top), .read_address(address_top), .writeData(rd2_top), .memData_out(memData_top));
    
    // Mux final para escolher se o que vai voltar pro registrador veio da conta da ALU ou veio da memória
    mux3 mem_mux(.select3(memToReg_top), .a3(address_top), .b3(memData_top), .mux3_out(writeBack_top));
endmodule