import subprocess

if __name__ == '__main__':
    runcommand = "java -cp .:h2o-genmodel.jar main 0 2 1 3 0"
    result = subprocess.check_output(runcommand.split())
    print(result)
