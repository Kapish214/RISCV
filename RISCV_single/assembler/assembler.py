import os

print("Current folder:", os.getcwd())

REG = {f"x{i}": i for i in range(32)}

R_TYPE = {
    "add": ("0110011", "000", "0000000"),
    "sub": ("0110011", "000", "0100000"),
    "sll": ("0110011", "001", "0000000"),
    "slt": ("0110011", "010", "0000000"),
    "xor": ("0110011", "100", "0000000"),
    "srl": ("0110011", "101", "0000000"),
    "sra": ("0110011", "101", "0100000"),
    "or" : ("0110011", "110", "0000000"),
    "and": ("0110011", "111", "0000000"),
    "mul": ("0110011", "000", "0000001"),
    "div": ("0110011", "100", "0000001")
}

I_TYPE = {
    "addi": ("0010011", "000"),
    "andi": ("0010011", "111"),
    "ori" : ("0010011", "110"),
    "xori": ("0010011", "100"),
    "slti": ("0010011", "010"),

    "lw": ("0000011", "010"),
    "jalr": ("1100111", "000")
}

S_TYPE = {
    "sw": ("0100011", "010")
}

B_TYPE = {
    "beq": ("1100011", "000"),
    "bne": ("1100011", "001"),
    "blt": ("1100011", "100"),
    "bge": ("1100011", "101")
}

U_TYPE = {
    "lui":   "0110111",
    "auipc": "0010111"
}

J_TYPE = {
    "jal": "1101111"
}

# --- STEP 1: New instruction dictionary updated here ---
CUSTOM_TYPE = {
    "smat": "0001011",    # CUSTOM-0 opcode
    "smrd": "0001011"     # CUSTOM-0 opcode
}

C_TYPE = {
    "c.mv":        "CR",
    "c.add":       "CR",
    "c.jr":        "CR",
    "c.jalr":      "CR",
    "c.ebreak":    "CR",

    "c.addi":      "CI",
    "c.nop":       "CI",
    "c.li":        "CI",
    "c.lui":       "CI",
    "c.addi16sp":  "CI",
    "c.slli":      "CI",

    "c.lw":        "CL",

    "c.sw":        "CS",

    "c.beqz":      "CB",
    "c.bnez":      "CB",

    "c.j":         "CJ",
    "c.jal":       "CJ"
}

CREG = {f"x{i}": i - 8 for i in range(8, 16)}


def bin_signed(val, bits):
    if val < 0:
        val = (1 << bits) + val
    return format(val & ((1 << bits) - 1), f"0{bits}b")


def encode_r(inst, rd, rs1, rs2):
    opcode, funct3, funct7 = R_TYPE[inst]
    return (
        funct7 +
        format(REG[rs2], "05b") +
        format(REG[rs1], "05b") +
        funct3 +
        format(REG[rd], "05b") +
        opcode
    )


def encode_i(inst, rd, rs1, imm):
    opcode, funct3 = I_TYPE[inst]
    return (
        bin_signed(int(imm, 0), 12) +
        format(REG[rs1], "05b") +
        funct3 +
        format(REG[rd], "05b") +
        opcode
    )


def encode_s(inst, rs2, rs1, imm):
    opcode, funct3 = S_TYPE[inst]
    imm_bin = bin_signed(int(imm, 0), 12)
    return (
        imm_bin[:7] +
        format(REG[rs2], "05b") +
        format(REG[rs1], "05b") +
        funct3 +
        imm_bin[7:] +
        opcode
    )


def encode_b(inst, rs1, rs2, imm):
    opcode, funct3 = B_TYPE[inst]
    imm_bin = bin_signed(int(imm, 0), 13)
    return (
        imm_bin[0] +
        imm_bin[2:8] +
        format(REG[rs2], "05b") +
        format(REG[rs1], "05b") +
        funct3 +
        imm_bin[8:12] +
        imm_bin[1] +
        opcode
    )


def encode_u(inst, rd, imm):
    opcode = U_TYPE[inst]
    return (
        format(int(imm, 0), "020b") +
        format(REG[rd], "05b") +
        opcode
    )


def encode_j(inst, rd, imm):
    opcode = J_TYPE[inst]
    imm_bin = bin_signed(int(imm, 0), 21)
    return (
        imm_bin[0] +
        imm_bin[10:20] +
        imm_bin[9] +
        imm_bin[1:9] +
        format(REG[rd], "05b") +
        opcode
    )


# --- STEP 2: Custom encoder updated here ---
def encode_custom(inst, *args):
    opcode = CUSTOM_TYPE[inst]

    if inst == "smat":
        funct7 = "0000000"
        rs2    = "00000"
        rs1    = "00000"
        funct3 = "000"
        rd     = "00000"
    
    elif inst == "smrd":
        funct7 = "0000000"
        rs2    = "00000"
        rs1    = format(REG[args[1]], "05b")
        funct3 = "001"
        rd     = format(REG[args[0]], "05b")

    return (
        funct7 +
        rs2 +
        rs1 +
        funct3 +
        rd +
        opcode
    )


def encode_c_cr(inst, *args):
    if inst == "c.mv":
        rd_rs1 = REG[args[0]]
        rs2    = REG[args[1]]
        return f"1000{rd_rs1:05b}{rs2:05b}10"
    elif inst == "c.add":
        rd_rs1 = REG[args[0]]
        rs2    = REG[args[1]]
        return f"1001{rd_rs1:05b}{rs2:05b}10"
    elif inst == "c.jr":
        rs1 = REG[args[0]]
        return f"1000{rs1:05b}0000010"
    elif inst == "c.jalr":
        rs1 = REG[args[0]]
        return f"1001{rs1:05b}0000010"
    elif inst == "c.ebreak":
        return "1001000000000010"


def encode_c_ci_nop():
    return "0000000000000001"


def encode_c_ci_addi(rd, imm):
    r    = REG[rd]
    imm6 = bin_signed(int(imm, 0), 6)
    return f"000{imm6[0]}{r:05b}{imm6[1:]}01"


def encode_c_ci_li(rd, imm):
    r    = REG[rd]
    imm6 = bin_signed(int(imm, 0), 6)
    return f"010{imm6[0]}{r:05b}{imm6[1:]}01"


def encode_c_ci_lui(rd, imm):
    r    = REG[rd]
    imm6 = bin_signed(int(imm, 0), 6)
    return f"011{imm6[0]}{r:05b}{imm6[1:]}01"


def encode_c_ci_addi16sp(imm):
    v  = int(imm, 0)
    if v < 0:
        v = (1 << 10) + v
    b9 = (v >> 9) & 1
    b8 = (v >> 8) & 1
    b7 = (v >> 7) & 1
    b6 = (v >> 6) & 1
    b5 = (v >> 5) & 1
    b4 = (v >> 4) & 1
    return f"011{b9}00010{b4}{b6}{b8}{b7}{b5}01"


def encode_c_ci_slli(rd, imm):
    r     = REG[rd]
    shamt = int(imm, 0)
    s5    = (shamt >> 5) & 1
    s4_0  = shamt & 0x1F
    return f"000{s5}{r:05b}{s4_0:05b}10"


def encode_c_cl(rd, rs1, imm):
    rd3  = CREG[rd]
    rs13 = CREG[rs1]
    v    = int(imm, 0)
    u5   = (v >> 5) & 1
    u4   = (v >> 4) & 1
    u3   = (v >> 3) & 1
    u2   = (v >> 2) & 1
    u6   = (v >> 6) & 1
    return f"010{u5}{u4}{u3}{rs13:03b}{u2}{u6}{rd3:03b}00"


def encode_c_cs(rs2, rs1, imm):
    rs23 = CREG[rs2]
    rs13 = CREG[rs1]
    v    = int(imm, 0)
    u5   = (v >> 5) & 1
    u4   = (v >> 4) & 1
    u3   = (v >> 3) & 1
    u2   = (v >> 2) & 1
    u6   = (v >> 6) & 1
    return f"110{u5}{u4}{u3}{rs13:03b}{u2}{u6}{rs23:03b}00"


def encode_c_cb(inst, rs1, imm):
    rs13   = CREG[rs1]
    v      = int(imm, 0)
    if v < 0:
        v = (1 << 9) + v
    b8 = (v >> 8) & 1
    b7 = (v >> 7) & 1
    b6 = (v >> 6) & 1
    b5 = (v >> 5) & 1
    b4 = (v >> 4) & 1
    b3 = (v >> 3) & 1
    b2 = (v >> 2) & 1
    b1 = (v >> 1) & 1
    funct3 = "110" if inst == "c.beqz" else "111"
    return f"{funct3}{b8}{b4}{b3}{rs13:03b}{b7}{b6}{b2}{b1}{b5}01"


def encode_c_cj(inst, imm):
    v = int(imm, 0)
    if v < 0:
        v = (1 << 12) + v
    b11 = (v >> 11) & 1
    b10 = (v >> 10) & 1
    b9  = (v >> 9)  & 1
    b8  = (v >> 8)  & 1
    b7  = (v >> 7)  & 1
    b6  = (v >> 6)  & 1
    b5  = (v >> 5)  & 1
    b4  = (v >> 4)  & 1
    b3  = (v >> 3)  & 1
    b2  = (v >> 2)  & 1
    b1  = (v >> 1)  & 1
    funct3 = "101" if inst == "c.j" else "001"
    return f"{funct3}{b11}{b4}{b9}{b8}{b10}{b6}{b7}{b3}{b2}{b1}{b5}01"


mem_file = os.path.abspath("../src/program.mem")

print("Writing to:", mem_file)

open(mem_file, "w").close()

while True:

    line = input("asm> ").strip()

    if line == "exit":
        print("program.mem generated.")
        break

    line = line.replace(",", " ")
    parts = line.split()

    if len(parts) == 0:
        continue

    inst = parts[0].lower()
    is_16 = inst in C_TYPE

    if inst in R_TYPE:
        binary = encode_r(inst, parts[1], parts[2], parts[3])

    elif inst in ["addi", "andi", "ori", "xori", "slti"]:
        binary = encode_i(inst, parts[1], parts[2], parts[3])

    elif inst == "lw":
        rd = parts[1]
        imm, rs1 = parts[2].split("(")
        rs1 = rs1[:-1]
        binary = encode_i(inst, rd, rs1, imm)

    elif inst == "jalr":
        rd = parts[1]
        imm, rs1 = parts[2].split("(")
        rs1 = rs1[:-1]
        binary = encode_i(inst, rd, rs1, imm)

    elif inst == "sw":
        rs2 = parts[1]
        imm, rs1 = parts[2].split("(")
        rs1 = rs1[:-1]
        binary = encode_s(inst, rs2, rs1, imm)

    elif inst in B_TYPE:
        binary = encode_b(inst, parts[1], parts[2], parts[3])

    elif inst in U_TYPE:
        binary = encode_u(inst, parts[1], parts[2])

    elif inst == "jal":
        binary = encode_j(inst, parts[1], parts[2])

    elif inst in ("c.mv", "c.add", "c.jr", "c.jalr", "c.ebreak"):
        binary = encode_c_cr(inst, *parts[1:])

    elif inst == "c.nop":
        binary = encode_c_ci_nop()

    elif inst == "c.addi":
        binary = encode_c_ci_addi(parts[1], parts[2])

    elif inst == "c.li":
        binary = encode_c_ci_li(parts[1], parts[2])

    elif inst == "c.lui":
        binary = encode_c_ci_lui(parts[1], parts[2])

    elif inst == "c.addi16sp":
        binary = encode_c_ci_addi16sp(parts[1])

    elif inst == "c.slli":
        binary = encode_c_ci_slli(parts[1], parts[2])

    elif inst == "c.lw":
        rd = parts[1]
        imm, rs1 = parts[2].split("(")
        rs1 = rs1[:-1]
        binary = encode_c_cl(rd, rs1, imm)

    elif inst == "c.sw":
        rs2 = parts[1]
        imm, rs1 = parts[2].split("(")
        rs1 = rs1[:-1]
        binary = encode_c_cs(rs2, rs1, imm)

    elif inst in ("c.beqz", "c.bnez"):
        binary = encode_c_cb(inst, parts[1], parts[2])

    elif inst in ("c.j", "c.jal"):
        binary = encode_c_cj(inst, parts[1])

    # --- STEP 3: Parsing logic updated here ---
    elif inst in CUSTOM_TYPE:
        binary = encode_custom(inst, *parts[1:])

    else:
        print("Unsupported instruction")
        continue

    if is_16:
        hex_instr = f"{int(binary,2):04X}"
        print("Binary:", binary)
        print("Hex   :", f"0x{hex_instr}")

        word = int(binary, 2)
        b0 = word & 0xFF
        b1 = (word >> 8) & 0xFF

        with open(mem_file, "a") as f:
            f.write(f"{b0:02X}\n")
            f.write(f"{b1:02X}\n")

        print(f"Written: {b0:02X} {b1:02X}")

    else:
        hex_instr = f"{int(binary,2):08X}"
        print("Binary:", binary)
        print("Hex   :", f"0x{hex_instr}")

        word = int(binary, 2)
        b0 = word & 0xFF
        b1 = (word >> 8) & 0xFF
        b2 = (word >> 16) & 0xFF
        b3 = (word >> 24) & 0xFF

        with open(mem_file, "a") as f:
            f.write(f"{b0:02X}\n")
            f.write(f"{b1:02X}\n")
            f.write(f"{b2:02X}\n")
            f.write(f"{b3:02X}\n")

        print(f"Written: {b0:02X} {b1:02X} {b2:02X} {b3:02X}")