import re

def process_rsp_file(input_file, output_file):
    """
    Process RSP file containing SHA-256 test vectors and extract padded messages.

    Args:
        input_file (str): Path to input RSP file
        output_file (str): Path to output text file
    """
    # Read the input file
    with open(input_file, 'r') as f:
        content = f.read()

    # Extract all Msg entries using regex
    # Pattern looks for lines starting with "Msg = " followed by hex characters
    msg_pattern = re.compile(r'^Msg = ([a-f0-9]+)$', re.MULTILINE)
    messages = msg_pattern.findall(content)

    # Write messages to output file
    with open(output_file, 'w') as f:
        f.write("SHA-256 Padded Messages:\n\n")
        for i, msg in enumerate(messages):
            # Convert hex string to bytes and format nicely
            f.write(f"Message {i + 1}:\n")
            f.write(msg + "\n\n")

if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python script.py <input_rsp_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    try:
        process_rsp_file(input_file, output_file)
        print(f"Successfully processed {input_file} and wrote results to {output_file}")
    except Exception as e:
        print(f"Error processing file: {e}")
        sys.exit(1)
