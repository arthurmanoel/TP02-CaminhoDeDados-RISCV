# O valor 7 já deve estar previamente na posição 4 da memória.
lh x1, 4(x0)       # x1 = 7 
add x2, x1, x0     # x2 = 7 

# Operações bit a bit para testar a ULA (ANDI) e Somador
andi x3, x1, 28    # x3 = 7 & 28 = 4
andi x4, x1, 3     # x4 = 7 & 3 = 3
add x5, x3, x4     # x5 = 4 + 3 = 7
bne x1, x5, ERRO   # 7 != 7? Não, passa

# Testando OR
or x6, x3, x4      # x6 = 4 | 3 = 7
bne x1, x6, ERRO   # 7 != 7? Não, passa

# Testando SLL
andi x7, x1, 1     # x7 = 7 & 1 = 1
sll x8, x1, x7     # x8 = 7 << 1 = 14
andi x9, x8, 15    # x9 = 14 & 15 = 14
bne x8, x9, ERRO   # 14 != 14? Não, passa

# Sucesso! Se chegou aqui, guarda o 7 na posição 0
sh x1, 0(x0)       

FIM:
bne x0, x1, FIM    # Loop infinito para segurar a execução

ERRO:
# Falha! Se desviar para cá, guarda 0 na posição 0
andi x6, x0, 0     
sh x6, 0(x0)       
bne x0, x1, FIM    # Pula pro Loop
