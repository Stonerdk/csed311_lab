d = {}
d["0"] = "0000"
d["1"] = "0001"
d["2"] = "0010"
d["3"] = "0011"
d["4"] = "0100"
d["5"] = "0101"
d["6"] = "0110"
d["7"] = "0111"
d["8"] = "1000"
d["9"] = "1001"
d["a"] = "1010"
d["b"] = "1011"
d["c"] = "1100"
d["d"] = "1101"
d["e"] = "1110"
d["f"] = "1111"
j = 0
with open("./memory.txt", "r") as f:
    for line in f.readlines():
        binary = d[line[0]] + d[line[1]] + d[line[2]] + d[line[3]]
        opcode = int(binary[:4], 2)
        rs = "$" + str(int(binary[4:6], 2))
        rt = "$" + str(int(binary[6:8], 2))
        rd = "$" + str(int(binary[8:10], 2))
        # print(j, binary, rs, rt, rd)
        func = int(binary[10:16], 2)
        imm = str(int(binary[8:], 2) - 128 * int(binary[8]))
        target = str(int(binary[4:], 2))
        i = str(j)
        # print(line[:4], opcode, func)
        if opcode == 15:
            if func == 0:
                print(i + ". " +rd, "<-", rs, "+", rt)
            elif func == 1:
                print(i + ". " +rd, "<-", rs, "-", rt)
            elif func == 2:
                print(i + ". " +rd, "<-", rs, "&", rt)
            elif func == 3:
                print(i + ". " +rd, "<-", rs, "|", rt)
            elif func == 4:
                print(i + ". " +rd, "<-", "!" + rs)
            elif func == 5:
                print(i + ". " +rd, "<-", "-" + rs)
            elif func == 6:
                print(i + ". " +rd, "<-", rs, "<<", 1)
            elif func == 7:
                print(i + ". " +rd, "<-", rs, ">>", 1)
            elif func == 25:
                print(i + ". " +"pc <-", rs)
            elif func == 26:
                print(i + ". " +"$2 <- pc, pc <-", rs)
            elif func == 28:
                print(i + ". " +"output <- ", rs)
            elif func == 29:
                print(i + ". " +"hlt")
        elif opcode == 4:
            print(i + ". " +rt, "<-", rs, "+", imm)
        elif opcode == 5:
            print(i + ". " +rt, "<-", rs, "|", imm)
        elif opcode == 6:
            print(i + ". " +rt, "<-", imm, "<<", 8)
        elif opcode == 7:
            print(i + ". " +rt, "<-", "MEM[" + rs, "+", imm + "]")
        elif opcode == 8:
            print(i + ". " +"MEM[" + rs, "+", imm + "] <-", rt)
        elif opcode == 0:
            print(i + ". " +"if " + rs, "!=" + rt, "then pc +=", imm, "+ 1")
        elif opcode == 1:
            print(i + ". " +"if " + rs, "==" + rt, "then pc +=" + imm, "+ 1")
        elif opcode == 2:
            print(i + ". " +"if " + rs, "> 0 then pc +=" + imm + " + 1")
        elif opcode == 3:
            print(i + ". " +"if " + rs, "< 0 then pc +=" + imm + " + 1")
        elif opcode == 9:
            print(i + ". " +"pc <-", target)
        elif opcode == 10:
            print(i + ". " +"$2 <- pc, pc <-", target)
        j += 1