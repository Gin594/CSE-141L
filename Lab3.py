import re

print('Running Lab3:')



#fileObj = open("filename", "mode") 
filename = "int2flt_assembly_code.txt"

read_file = open(filename, "r") 

#Print read_file

#w_file is the file we are writing to

w_file = open("int2flt_machine_code.txt", "w")


#Open a file name and read each line
#to strip \n newline chars
#lines = [line.rstrip('\n') for line in open('filename')]  

#1. open the file
#2. for each line in the file,
#3.     split the string by white spaces
#4.      if the first string == SET then op3 = 0, else op3 = 1
#5.      
with open(filename, 'r') as f:
  for line in f:
    print(line)
    str_array = line.split()
    instruction = str_array[0]
    try:
      op1 = "{0:04b}".format(int(re.findall(r"\d+", str_array[1])[0]))
    except:
      pass
    else:

      if instruction == "set":
        op3 = "1"
        imm = str_array[1]  #need to reformat without the hashtag
        imm = imm[1:]
        bin_imm = '{0:08b}'.format(int(imm,16)) #8 bit immediate
        #str_array[2] should be the comment
        return_set = op3 +'_'+ bin_imm + '\t' + "//" + " " + instruction \
             + " " + imm
        w_file.write(return_set + '\n')
      else:
        op3 = "0"

        if instruction == "move":
          opcode = "0000"
        elif instruction == "assign":
          opcode = "0001"
        elif instruction == "add":
          opcode = "0010"
        elif instruction == "sub":
          opcode = "0011"
        elif instruction == "load":
          opcode = "0100"
        elif instruction == "store":
          opcode = "0101"
        elif instruction == "and":
          opcode = "0110"
        elif instruction == "lsl":
          opcode = "0111"
        elif instruction == "lsr":
          opcode = "1000"
        elif instruction == "orr":
          opcode = "1001"
        elif instruction == "b":
          opcode = "1010"
          op1 = '0000'          # b have no parameter
        elif instruction == "beq":
          opcode = "1011"
        elif instruction == "blt":
          opcode = "1100"
        elif instruction == "bge":
          opcode = "1101"
        elif instruction == "bgt":
          opcode = "1111"
        else:
          opcode = "error: undefined opcode"
          print( "error: undefined opcode")
          break
        return_rtype = op3 +'_'+ opcode +'_'+ op1+'\t' + "//" + " " + instruction + " "  + " r{}".format(int(re.findall(r"\d+", str_array[1])[0]))
        w_file.write(return_rtype + '\n' )



w_file.close()
   

      


