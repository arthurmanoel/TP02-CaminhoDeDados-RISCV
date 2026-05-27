`timescale 1ns / 1ps

//Responsavel por executar todas as operacoes matematicas e logicas e testar condicoes de salto
module ALU(A, B, control_in, ALU_result, zero);
    input [31:0] A, B;
    input [3:0] control_in;
    output reg zero; //É uma flag de 1 bit. Ela serve para ver se no caso do bne se os valores comparados são iguais.
    output reg [31:0] ALU_result;

    always @(*) begin
        case (control_in)
            4'b0000: begin zero <= 0; ALU_result <= A & B; end // ANDI
            4'b0001: begin zero <= 0; ALU_result <= A | B; end // OR
            4'b0010: begin zero <= 0; ALU_result <= A + B; end // ADD / LH / SH
            4'b0011: begin zero <= 0; ALU_result <= A << B[4:0]; end // SLL
            4'b0110: begin if(A==B) zero <= 1; else zero <= 0; ALU_result <= A - B; end // BNE (Usa sub para comparar)
            default: begin zero <= 0; ALU_result <= 32'b0; end
        endcase
    end
endmodule