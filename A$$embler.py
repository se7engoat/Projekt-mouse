def readFile(file):
    
        try:
            with open(file, 'r') as f:
                counter = 0
                with open('Complete_Demo_ROM_assembled.txt', 'w') as out_file:
                    for line in f: #reading each line in the file
                        if line.strip().startswith("//"): #remove all the // in the line
                            continue
                        instruction = line.strip().replace(";", "")  # Strip special characters like ';'
                        lineArr = []
                        for element in instruction.split():
                            if element.startswith("//"):
                                break
                            elif element == "0x85":
                                lineArr.append("@0xFE 0x85\n")
                            elif element == "0x5C":
                                lineArr.append("@0xFF 0x5C\n")
                            elif (element.startswith("0x")) or element in Opcode_mapping:
                                lineArr.append("@0x" + hex(counter)[2:].upper().zfill(2))
                                lineArr.append(element)
                                counter += 1
                            
                                
                        print(lineArr)
                        for instr in lineArr:
                            if(instr.startswith("@0x")):
                                out_file.write(f"{instr}" + " ") #write the line addr of ROM and insert a white space
                            elif(instr in Opcode_mapping):
                                out_file.write(f"{Opcode_mapping[instr]}\n")
                            else:
                                out_file.write(f"{instr}\n")
            print("Writing is done.")
        except Exception as e:
            print(f"An error occurred: {e}, counter: {counter}, line: {line}")
        


Opcode_mapping = {
        #load and store instructions
        "READ_regA" : "0x00",
        "READ_regB" : "0x01",
        "LOAD_regA" : "0x02",
        "LOAD_regB" : "0x03",
        
        #arithmetic instructions
        "ADD_regA" : "0x04",
        "SUB_regA" : "0x14",
        "MUL_regA" : "0x24",
        "LSHIFT_regA" : "0x34",
        "RSHIFT_regA" : "0x44",
        "INCA_regA" : "0x54",
        "INCB_regA" : "0x64",
        "DECA_regA" : "0x74",
        "DECB_regA" : "0x84",
        "EQ_regA" : "0x94",
        "EQA_regA" : "0xA4",
        "EQB_regA" : "0xB4",
        "ADD_regB" : "0x05",
        "SUB_regB" : "0x15",
        "MUL_regB" : "0x25",
        "LSHIFT_regB" : "0x35",
        "RSHIFT_regB" : "0x45",
        "INCA_regB" : "0x55",
        "INCB_regB" : "0x65",
        "DECA_regB" : "0x75",
        "DECB_regB" : "0x85",
        "EQ_regB" : "0x95",
        "EQA_regB" : "0xA5",
        "EQB_regB" : "0xB5",

        #jump instructions
        "BREQ" : "0x96",
        "BGTQ" : "0xA6",
        "BLTQ" : "0xB6",
        "GOTO" : "0x07",
        "IDLE" : "0x08",
        "FUNC" : "0x09",
        "RETURN" : "0x0A",
        "DEREF_A" : "0x0B",
        "DEREF_B" : "0x0C"
}

if __name__ == "__main__":
    file_path = "C:\\Users\\s2736992\\Desktop\\Projekt-mouse\\instructions_ROM.txt" 
    readFile(file_path)