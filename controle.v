`timescale 1ns / 1ps

//Este módulo olha para opcode e decide o caminho dos dados
module unidadeControle(instruction, branch, memRead, memToReg, ALUop, memWrite, ALUSrc, regWrite);
    input [6:0] instruction;
    output reg branch, memRead, memToReg, memWrite, ALUSrc, regWrite;
    output reg [1:0] ALUop;

    always @(*) begin 
        case(instruction)
            7'b0110011 : {ALUSrc, memToReg, regWrite, memRead, memWrite, branch, ALUop} <= 8'b001000_10; // Tipo-R (ADD, OR, SLL)
            7'b0000011 : {ALUSrc, memToReg, regWrite, memRead, memWrite, branch, ALUop} <= 8'b111100_00; // LH
            7'b0100011 : {ALUSrc, memToReg, regWrite, memRead, memWrite, branch, ALUop} <= 8'b100010_00; // SH
            7'b1100011 : {ALUSrc, memToReg, regWrite, memRead, memWrite, branch, ALUop} <= 8'b000001_01; // BNE
            7'b0010011 : {ALUSrc, memToReg, regWrite, memRead, memWrite, branch, ALUop} <= 8'b101000_10; // ANDI colocámos ALUop = 10, pois a ULA percebe que tem de ler o funct3 para saber que a operação não é de soma, mas sim um AND
            default    : {ALUSrc, memToReg, regWrite, memRead, memWrite, branch, ALUop} <= 8'b000000_00;
        endcase
    end
endmodule

//Pega a instrução recebida da unidadeControle. Utiliza o sinal ALUop em conjunto com o campo funct3 da instrução para determinar o código exato de 4 bits que dirá à ULA a operação matemática a executar
module ALU_Control(ALUop, funct7, funct3, control_out);
    input funct7;
    input [2:0] funct3;
    input [1:0] ALUop;
    output reg [3:0] control_out;

    always @(*) begin
        case(ALUop)
            2'b00: control_out <= 4'b0010; // Load/Store usa Add
            2'b01: control_out <= 4'b0110; // Branch usa Sub para comparar
            2'b10: begin 
                case(funct3)
                    3'b000: control_out <= 4'b0010; // ADD
                    3'b110: control_out <= 4'b0001; // OR
                    3'b001: control_out <= 4'b0011; // SLL
                    3'b111: control_out <= 4'b0000; // ANDI
                    default: control_out <= 4'b0010;
                endcase
            end
            default: control_out <= 4'b0010;
        endcase
    end
endmodule

//Pega os imediatos de dentro da instrução de 32 bits. Como a posição dos bits varia conforme o tipo da instrução (Tipo-I, Tipo-S, Tipo-B), este módulo remonta o número e realiza a extensão de sinal para 32 bits.
module immConfig (opcode, instruction, immExt);
    input [6:0] opcode;
    input [31:0] instruction;
    output reg [31:0] immExt;

    always @(*) begin
        case(opcode)
            7'b0000011 : immExt <= {{20{instruction[31]}}, instruction[31:20]}; // LH
            7'b0010011 : immExt <= {{20{instruction[31]}}, instruction[31:20]}; // ANDI 
            7'b0100011 : immExt <= {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // SH
            7'b1100011 : immExt <= {{19{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:8], 1'b0}; // BNE
            default    : immExt <= 32'b0;
        endcase
    end
endmodule