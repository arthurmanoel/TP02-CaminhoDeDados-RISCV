`timescale 1ns / 1ps

module tb_top();
    reg clk;
    reg reset;
    integer i;
    // Inicializando processador do top.v
    top uut (.clk(clk), .reset(reset));


    always #5 clk = ~clk;

    initial begin
        
        $dumpfile("wave.vcd");    // Nome do arquivo de onda 
        $dumpvars(0, tb_top);    

        // Reseta pra limpar lixo dos registradores
        clk = 0;
        reset = 1;  
        
        #12;
        reset = 0; 
        
        // Carrega os arquivos txt da memória
        // Feito após o reset para que o laço da memória não o apague.
        $readmemb("programa_bin.txt", uut.Inst_mem.I_mem);
        $readmemb("registradores.txt", uut.registerFile.registers);
        $readmemb("memoria.txt", uut.data_mem.Data_memory);

        $display("======= INICIO DA SIMULACAO CAMINHO DE DADOS (GRUPO 17) =======");
        
        #250;
        
        $display("\n=== ESTADO FINAL DOS 32 REGISTRADORES ===");
        for (i = 0; i < 32; i = i + 1) begin
            $display("Registrador [x%2d]: %d", i, uut.registerFile.registers[i]);
        end
        
        $display("\n=== PRIMEIRAS 32 POSICOES DA MEMORIA DE DADOS ===");
        for (i = 0; i < 32; i = i + 1) begin
            $display("Memoria Endereco [%2d]: %d", i * 4, uut.data_mem.Data_memory[i]);
        end

        $display("\n======= FIM DA SIMULACAO =======");
        $finish;
    end
endmodule