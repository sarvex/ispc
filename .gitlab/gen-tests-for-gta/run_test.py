import os
import stat
import subprocess
import sys

# checks whether print ouput is correct
# (whether test and reference outputs are same)
# NOTE: output contains both test and reference lines
def check_print_output(output):
    lines = output.splitlines()
    if len(lines) == 0 or len(lines) % 2:
        return False
    else:
        return lines[0:len(lines)//2] == lines[len(lines)//2:len(lines)]

def run():
    # find binary
    for element in os.scandir('.'):
        if element.is_file() and 'ispc.run' in element.name:
             binName = element.name
             break

    binTest = "./" + binName
    st = os.stat(binTest)
    os.chmod(binTest, st.st_mode | stat.S_IEXEC)
    proc = subprocess.Popen(["/usr/bin/timeout", "20s", binTest], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out = proc.communicate()
    returnCode = proc.poll()
    if returnCode != 0:
        exit(returnCode)

    # early return if not print test
    if not binName.startswith("print"):
        exit(0)

    output = ""
    output += out[0].decode("utf-8", errors='ignore')
    output += out[1].decode("utf-8", errors='ignore')
    print(output)



    output_equality = check_print_output(output)
    if not output_equality:
        print("Print outputs check failed\n")
        exit(1)

if __name__ == '__main__':
    run()

