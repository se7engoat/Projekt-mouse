def read_file(file_path):
    lines = []
    with open(file_path, 'r') as file:
        for line in file:
            stripped_line = line.strip()  # remove leading and trailing whitespace
            if stripped_line.startswith("//"):
                continue  # skip this line if it starts with //
            if stripped_line:  # optionally, check if line is not empty
                lines.append(stripped_line)
                print(lines)
                lines.append(",")



    return lines 
    #this method is goign to return a list of all the lines 
    #separated by a ",". The comma is the delimiter.



# Example usage:
if __name__ == "__main__":
    Opcode = {
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
    file_path = "example.txt"  # Replace with your file's path
    result_lines = read_file(file_path)
    print("Processed lines:", result_lines)


def map_opcode_lines(lines_list):
    """
    Processes the list of lines from the file.
    Each line is assumed to be comma-delimited (e.g. "READ_regA, 0x1234").
    The function splits each line into tokens and does the following:
      - If a token is a key in the Opcode dictionary, its corresponding value is appended.
      - If the token is the delimiter "*" then it is skipped.
      - If the token is not an opcode (e.g. an address), it is appended and immediately followed
        by the delimiter "$" to mark a line boundary.
    Returns a new list of tokens.
    """
    new_list = []
    for line in lines_list:
        # Split the line by comma and strip spaces from each token.
        tokens = [token.strip() for token in line.split(',')]
        for token in tokens:
            if token in Opcode:
                # Mapped opcode is the value from the dictionary.
                new_list.append(Opcode[token])
            elif token == "*":
                # If token is '*' then do nothing.
                continue
            else:
                # For tokens that are not opcodes (like addresses), add the token and a delimiter.
                new_list.append(token)
                new_list.append("$")
    return new_list

def write_output_file(token_list, output_file_path):
    """
    Reads the token list from map_opcode_lines and writes to an output file.
    Tokens are concatenated into a single line until the "$" delimiter is encountered,
    which causes a newline to be written.
    Returns the output file path.
    """
    with open(output_file_path, 'w') as out_file:
        line_buffer = ""
        for token in token_list:
            if token == "$":
                # When the delimiter is found, write the current line buffer and start a new line.
                out_file.write(line_buffer.rstrip() + "\n")
                line_buffer = ""
            else:
                # Append token with a space for separation.
                line_buffer += token + " "
        # Write any remaining text in the buffer.
        if line_buffer.strip():
            out_file.write(line_buffer.rstrip() + "\n")
    return output_file_path

# Example usage:
if __name__ == "__main__":
    # Step 1: Read the file and get cleaned lines
    input_file = "input.txt"  # Replace with your actual input file path
    lines = read_file(input_file)
    
    # Step 2: Map opcodes and tokens into a new list.
    mapped_tokens = map_opcode_lines(lines)
    print("Mapped tokens:", mapped_tokens)
    
    # Step 3: Write the tokens into an output file, grouping tokens until the '$' delimiter.
    output_file = "output.txt"  # Replace with your desired output file path
    final_output = write_output_file(mapped_tokens, output_file)
    
    print(f"Processed output has been written to: {final_output}")
