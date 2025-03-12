import re
import sys

def process_dot_file(input_file,output_file):
    # Open the input file for reading
    with open(input_file, 'r') as infile:
        lines = infile.readlines()

    new_lines = []
    
    # Process each line
    for line in lines:
        # print(line)
        # Check for a transition line (sX -> sY [label="..."])
        match = re.match(r'\s*(s\d+)\s*->\s*(s\d+)\s*\[label\s*=\s*"((?:[^"]|"[^"]*")*)"\s*\];', line)

        # print(match)
        if match:
            state_transition = match.group(1)
            label_content = match.group(2)
            line_end = match.group(3)
            
            # Split the label by comma and create separate transitions
            print(state_transition,":",label_content,":",line_end)
            line_end=line_end.replace(",","")
            line_end=line_end.replace(".","")
            labels = label_content.split(',')
            # labels = [ for label in label_content]
            
            # Create a new line for each label
            # for label in label_content.split(','):
            new_lines.append(f'\t{state_transition} -> {label_content}[label="{line_end}"]\n')
        else:
            # If not a transition line, just add it as is
            new_lines.append(line)
    
    # Write the modified content to the output file
    with open(output_file, 'w') as outfile:
        outfile.writelines(new_lines)

# Usage
# input_dot_file = "FSM/FSM_B.dot"
# output_dot_file = "FSM/FSM_B_new.dot"
# process_dot_file(input_dot_file, output_dot_file)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 processdotFile.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    process_dot_file(input_file, output_file)