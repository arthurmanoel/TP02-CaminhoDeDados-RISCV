`timescale 1ns / 1ps

module instruction_mem(clk, reset, read_address, instruction_out);
    input clk, reset;
    input [31:0] read_address;
    output [31:0] instruction_out;
    
    reg [31:0] I_mem[63:0];

    assign instruction_out = I_mem[read_address >> 2];

endmodule


// Banco de Registradores

module reg_file (clk, reset, regWrite, rs1, rs2, rd, writeData, read_data1, read_data2);

    input clk, reset, regWrite;
    input [4:0] rs1, rs2, rd;
    input [31:0] writeData;
    output [31:0] read_data1, read_data2;
    integer k;
    reg [31:0] registers [31:0];

    // Só gravar quando o clock subir
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            // Resetando pra limpar lixo de memoria
            for(k=0; k<32; k=k+1) registers[k] <= 32'b00;
        end else if (regWrite && rd != 0) begin
            // Grava apenas se o sinal de controle deixar e se não for para o x0
            registers[rd] <= writeData;
        end
    end

    assign read_data1 = registers[rs1];
    assign read_data2 = registers[rs2];

endmodule

module data_memory(clk, reset, memWrite, memRead, read_address, writeData, memData_out);
    input clk, reset, memWrite, memRead;
    input [31:0] read_address, writeData;
    output [31:0] memData_out;
    integer k;

    reg [31:0] Data_memory [63:0];
    wire [29:0] word_addr = read_address[31:2]; // Ajustando o endereço
    // Escreve na subida do clock
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            for(k=0; k<64; k=k+1) Data_memory[k] <= 32'b00;
        end else if (memWrite) begin
            Data_memory[word_addr][15:0] <= writeData[15:0];
        end
    end

    wire [15:0] halfword = Data_memory[word_addr][15:0];
    // Se memRead estiver ativo pega os 16bits e extende o sinal (duplica o bit mais significagtivo) pra ser 32bits 
    assign memData_out = (memRead) ? { {16{halfword[15]}}, halfword } : 32'b00;
endmodule