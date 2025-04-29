def format_hex_file(input_file, output_file):
    """
    Reads a hex file, adds a line break after every 2 characters in each line,
    and saves the result to a new file.

    Args:
        input_file (str): Path to the input hex file.
        output_file (str): Path to save the formatted hex file.
    """
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            # Remove any whitespace and split the line into chunks of 2 characters
            formatted_line = '\n'.join(line.strip()[i:i+2] for i in range(0, len(line.strip()), 2))
            outfile.write(formatted_line + '\n')

if __name__ == "__main__":
    # Example usage
    input_file = "inputBlock.hex"  # Replace with the path to your input hex file
    output_file = "inputFormatted.hex"  # Replace with the path to your output file

    format_hex_file(input_file, output_file)
    print(f"Formatted hex file saved to {output_file}")