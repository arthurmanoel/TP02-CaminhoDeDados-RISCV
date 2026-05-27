`timescale 1ns / 1ps

//Guarda o endereço da instrução atual. Atualiza o endereço a cada subida do clock ou zera o endereço se o reset for acionado
module program_counter(clk, reset, pc_in, pc_out);
    input clk, reset;
    input [31:0] pc_in;
    output reg [31:0] pc_out;
    always @(posedge clk or posedge reset) begin
        if(reset) pc_out <= 32'b00;
        else pc_out <= pc_in;
    end
endmodule

//Calcula o endereço sequencial da próxima instrução na memória, somando 4 bytes ao endereço atual
module PCplus4(fromPC, nextPC);
    input [31:0] fromPC; output [31:0] nextPC;
    assign nextPC = fromPC+4;
endmodule

//Mux para ALUSrc: decide se a 2ª entrada da ULA será o valor de um registo (para add, or) ou o valor de um Imediato (para andi, lh, sh)
module mux1 (select1, a1, b1, mux1_out);
    input select1; input [31:0] a1, b1; output [31:0] mux1_out;
    assign mux1_out = (select1==1'b0) ? a1 : b1;
endmodule

//Mux para o PC: decide se a próxima instrução será a sequencial (PC+4) ou se será um endereço de salto (caso o bne seja verdadeiro)
module mux2 (select2, a2, b2, mux2_out);
    input select2; input [31:0] a2, b2; output [31:0] mux2_out;
    assign mux2_out = (select2==1'b0) ? a2 : b2;
endmodule

//Mux para o MemToReg: decide se o valor que vai ser guardado no Banco de Registos vem do resultado da ULA (ex: add) ou se vem de uma leitura da Memória de Dados (ex: lh)
module mux3 (select3, a3, b3, mux3_out);
    input select3; input [31:0] a3, b3; output [31:0] mux3_out;
    assign mux3_out = (select3==1'b0) ? a3 : b3;
endmodule

module AND_logic (branch, zero, and_out);
    input branch, zero; output and_out;
    assign and_out = branch & (~zero); // Os valores comparados na ULA têm de ser diferentes. Como a ULA emite zero = 1 quando os valores são iguais, nós invertemos o sinal (~zero). Assim, se a ULA diz que eles não são iguais (zero = 0), o ~zero vira 1, e o salto acontece (branch AND 1 = 1)
endmodule

//Este módulo é muito semelhante ao PCplus4, mas em vez de somar 4, ele soma valores variáveis para calcular o endereço exato para onde o código deve saltar
module adder(in_1, in_2, sum_out);
    input [31:0] in_1, in_2; output [31:0] sum_out;
    assign sum_out = in_1 + in_2;
endmodule