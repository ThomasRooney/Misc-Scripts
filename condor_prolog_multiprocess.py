

import subprocess, copy
import os.path

# Number of tests
NumTests = 5 # This will be run multiple times per condor batch


#executable      = """/usr/bin/sicstus"""
executable  = """/usr/local/sicstus4.2.1/bin/sicstus"""
#directory = "'/vol/bitbucket/tr111/Prolog-War-of-Life/my_wol.pl'"
script = "/home/thomas/Code/Prolog-War-of-Life/my_wol.pl"
execList      = [executable,
					"-l", script, "--goal"]

#arguments       = [""" -l '/vol/bitbucket/tr111/Prolog-War-of-Life/my_wol.pl' --goal 'test_strategy(#arg1, #arg2, #arg3).'"""]
arguments       = [""" -l '/vol/bitbucket/tr111/Prolog-War-of-Life/my_wol.pl' --goal 'test_strategy(#arg1, #arg2, #arg3).'"""]

# output_dir          = """/vol/bitbucket/tr111/Prolog-War-of-Life/Results_Condor/"""
output_dir = """/home/thomas/Code/Prolog-War-of-Life/results"""

strategies = ["minimax", "bloodlust", "random", "land_grab", "self_preservation"]

def form_runList(arg1, arg2, arg3):
	e = copy.copy(execList)	
	prolog_str = "test_strategy("+str(arg1)+", "+str(arg2)+", "	+str(arg3)+")."
	e.append(prolog_str)
	print e
	return e

def run_test(arg1, arg2, arg3, outFile):
	proc = subprocess.Popen(form_runList(arg1,arg2,arg3), stdout=outFile, shell=False)

def run_tests():
	for strat1 in strategies:
		for strat2 in strategies:
			outFile = output_dir + "/" + str(strat1) + "_" + str(strat2)
			i = 0
			while (os.path.isfile(outFile+str(i))):
				i+=1
			with open(outFile + str(i), "w+") as f:
				run_test(str(NumTests), str(strat1), str(strat2), f)


if __name__ == "__main__":
	run_tests()


