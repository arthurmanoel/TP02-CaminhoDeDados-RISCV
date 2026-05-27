import sys
import re

INSTRUCOES = {
    "add":  {"tipo": "R", "opcode": "0110011", "funct3": "000", "funct7": "0000000"},
    "or":   {"tipo": "R", "opcode": "0110011", "funct3": "110", "funct7": "0000000"},
    "sll":  {"tipo": "R", "opcode": "0110011", "funct3": "001", "funct7": "0000000"},
    "andi": {"tipo": "I", "opcode": "0010011", "funct3": "111"},
    "lh":   {"tipo": "I", "opcode": "0000011", "funct3": "001"},
    "sh":   {"tipo": "S", "opcode": "0100011", "funct3": "001"},
    "bne":  {"tipo": "B", "opcode": "1100011", "funct3": "001"},
}

TABELA_LABELS = {}


def monta_R(info, rs2, rs1, rd):
    montado = info["funct7"]
    montado += regs(rs2)
    montado += regs(rs1)
    montado += info["funct3"]
    montado += regs(rd)
    montado += info["opcode"]
    return montado



def monta_I(info, imed1, rs1, rd):
    montado = imed(imed1)
    montado += regs(rs1)
    montado += info["funct3"]
    montado += regs(rd)
    montado += info["opcode"]
    return montado



def monta_S(info, imeds,rs2,rs1):
    imediato = imed(imeds)
    p1_imed = imediato[0:7]
    p2_imed = imediato[7:12]
    montado = p1_imed
    montado += regs(rs2)
    montado += regs(rs1)
    montado += info["funct3"]
    montado += p2_imed
    montado += info["opcode"]
    return montado


def monta_B(info, rs1, rs2, imeds):
    imediato = imed(imeds)
    p1 = imediato[0]
    p2 = imediato[2:8]
    p3 = imediato[8:12]
    p4 = imediato[1]
    montado = p1
    montado += p2
    montado += regs(rs2)
    montado += regs(rs1)
    montado += info["funct3"]
    montado += p3
    montado += p4
    montado += info["opcode"]
    return montado


def regs(local):
    conv = int(local.strip("x,"))
    conv = format(conv, '05b')
    return conv



def imed(value):
    value = int(value)
    if(value < 0):
        value = value + 2**12
    return format(value, f'0{12}b')

# Serve para separar os valores que são enderessos ex: 0(x10)
def addressReading(value):
    resultado = re.search(r"(-?\d+)\((.*?)\)", value) #separa em dois grupos. Ex: 0(x10) -> grupo(1) = o elemento antes do parenteses (0), grupo(2) = elemento dentro dos parenteses (x10).
    return resultado

if len(sys.argv) < 2:
    print("Uso: python montador.py arquivo.asm")
    sys.exit(1)


nome_arquivo = sys.argv[1]

with open(nome_arquivo, "r") as f:
    conteudo = f.read()


linhas = conteudo.splitlines() #separa o conteudo em linhas Ex:["add x2, x2, x3", "lh x5, 0(x10)", ...]

contador_bytes = 0 #contador para descobrir o endereço da função do bne

#primeira iteração para pegar apenas o endereço da função(se tiver) que o bne chama
for linha in linhas:
    linha = linha.strip() #Limpa qualquer espaço que pode ter nas bordas
    if not linha: #caso a linha seja vazia, pula pra outra
        continue

    if ":" in linha:
        partes = linha.split(":") #Ex: |Fim| : |add x2, x2, x3|
        nome_label = partes[0].strip()#"Fim"

        TABELA_LABELS[nome_label] = contador_bytes #salva o endereço da função

        resto_daLinha = partes[1].strip()

        if len(resto_daLinha) > 0: #se existe instrução na função
            contador_bytes += 4
    else:
        contador_bytes += 4 #os endereços são de 4 em 4 bytes

#segunda iteração agora com o objetivo de achar qual o tipo de instrução se enquadra e chamar o montador
contador_bytes = 0
resultados = []



for linha in linhas:
    linha = linha.strip()
    if not linha:
        continue

    if ":" in linha:
        linha = linha.split(":")[1].strip() #caso caia na linha que é da função, vai apenas pegar a instrução dela

    if not linha:
        continue

    tokens = linha.split() #Ex: ["add", "x2,", "x2," "x3"]
    operacao = tokens[0] #"add"
    dicionarioOperacao = INSTRUCOES[operacao]

    if operacao == "add":
        rd = tokens[1].strip(",") #tira a virgula que acabou ficando depois do split
        rs1 = tokens[2].strip(",")
        rs2 = tokens[3].strip(",")

        resultado = monta_R(dicionarioOperacao, rs2, rs1, rd)
        resultados.append(resultado)




    if operacao == "or":
        rd = tokens[1].strip(",")
        rs1 = tokens[2].strip(",")
        rs2 = tokens[3].strip(",")
        resultado = monta_R(dicionarioOperacao, rs2, rs1, rd)
        resultados.append(resultado)


    if operacao == "sll":
        rd = tokens[1].strip(",")
        rs1 = tokens[2].strip(",")
        rs2 = tokens[3].strip(",")
        resultado = monta_R(dicionarioOperacao, rs2, rs1, rd)
        resultados.append(resultado)



    if operacao == "andi":
        rd = tokens[1].strip(",")
        rs1 = tokens[2].strip(",")
        imediato = tokens[3].strip(",")
        resultado = monta_I(dicionarioOperacao, imediato, rs1, rd)
        resultados.append(resultado)

    if operacao == "lh":
        rd = tokens[1].strip(",")
        address = addressReading(tokens[2].strip(",")) #Ex: addressReading("0(x10)")
        rs1 = address.group(2) # x10
        imediato = address.group(1) # 0

        resultado = monta_I(dicionarioOperacao, imediato, rs1, rd)
        resultados.append(resultado)

    if operacao == "sh":
        rs2 = tokens[1].strip(",")
        address = addressReading(tokens[2].strip(","))
        rs1 = address.group(2)
        imediato = address.group(1)

        resultado = monta_S(dicionarioOperacao, imediato, rs2, rs1)
        resultados.append(resultado)

    if operacao == "bne":
        rs1 = tokens[1].strip(",")
        rs2 = tokens[2].strip(",")

        label = tokens[3].strip(",")

        if label in TABELA_LABELS:
            enderecoAlvo = TABELA_LABELS[label]

            imediato = enderecoAlvo - contador_bytes

            resultado = monta_B(dicionarioOperacao, rs1, rs2, imediato)
            resultados.append(resultado)
        else:
            print(f"Erro: Não existe '{label}' não existe!")

    contador_bytes += 4


if "-o" in sys.argv:
    nome_saida = sys.argv[sys.argv.index("-o") + 1]
    with open(nome_saida, "w") as f:
        for r in resultados:
            f.write(r + "\n")
else:
    for r in resultados:
        print(r)