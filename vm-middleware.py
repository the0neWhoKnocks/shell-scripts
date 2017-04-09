#!/usr/bin/python
# -*- coding: utf-8 -*-

######################################################################
#                                                                    #
# [ Installation ]                                                   #
#                                                                    #
# I created a dir in my home dir called "sh" (for shell scripts).    #
# With that in mind, you can add the attached script in the sh dir,  #
# and add the below line to your .bashrc or .zshrc file.             #
#                                                                    #
# alias startvm="~/sh/vm-middleware.py --func startvm"               #
# alias stopvm="~/sh/vm-middleware.py --func stopvm"                 #
#                                                                    #
######################################################################

from multiprocessing import Process
import sys, getopt, time, subprocess

def main(argv):
  func = ''
  vmName = ''
  help = 'Usage: vm-middleware.py --func <functionName> -n <vmname> [-h]'
  headless = ''
  
  try:
    opts, args = getopt.getopt(argv, "hf:n:", ["func=","name="])
    
  except getopt.GetoptError:
    print help
    sys.exit(2)
  
  for opt, arg in opts:
    if opt in ("-h", "--headless"):
      headless = '--type headless'
    
    elif opt == "--func":
      func = arg
    
    elif opt in ("-n", "--name"):
      vmName = arg
    
  if ( vmName  == '' ): 
    print "[ERROR] No VM name provided"
    print help
    print "Available VM's are:"
    print subprocess.check_output('VBoxManage list vms', shell=True, stderr=subprocess.STDOUT)
    sys.exit(2)
  
  if (func == 'startvm'):
    startVM(vmName, headless)
  elif (func == 'stopvm'):
    stopVM(vmName)
  else:
    print "You specified a function that's not available"
    sys.exit(2)


def getVMIP(vmName):
  return subprocess.check_output('VBoxManage guestproperty enumerate "'+ vmName +'" | grep -E "Net/(0|1)/V4/IP, value: 192" | awk -F, \'{split($2,_," "); print _[2]}\'', shell=True, stderr=subprocess.STDOUT)
  

def checkIfVMBooted(vmName, num=1):
  time.sleep(3)
  vmIP = getVMIP(vmName)
  
  if ( vmIP == '' ):
    checkIfVMBooted(vmName, num+1)
  else:
    msgProcess.terminate()
    print "'"+ vmName +"' is running @ "+ vmIP


def bootingMsg(msgText='Loading'):
  spinner = spinningCursor()
  dots = progressDots()
  
  while True:
      msg = ' '+ msgText +' ['+ spinner.next() + '] '+ dots.next() +"\r"
      sys.stdout.write( msg )
      sys.stdout.flush()
      time.sleep(0.07)
      sys.stdout.write( '\b' * len(msg) )


def startVM(vmName, headless):
  try:
    subprocess.check_output('VBoxManage list runningvms | grep "'+ vmName +'"', shell=True, stderr=subprocess.STDOUT)
    vmIP = getVMIP(vmName)
    print "'"+ vmName +"' is already running @ "+ vmIP
    
  except subprocess.CalledProcessError as err:
    global msgProcess
    msgProcess = Process(target=bootingMsg, args=('Booting',))
    msgProcess.start()
    
    try:
      subprocess.check_output('VBoxManage startvm "'+ vmName +'" '+ headless, shell=True, stderr=subprocess.STDOUT)
      checkIfVMBooted(vmName)
      
    except subprocess.CalledProcessError as err:
      print err.output


def stopVM(vmName, waiting=False):
  try:
    if( waiting == False ):
      subprocess.check_output('VBoxManage controlvm "'+ vmName +'" acpipowerbutton', shell=True, stderr=subprocess.STDOUT)
      global msgProcess
      msgProcess = Process(target=bootingMsg, args=('Stopping',))
      msgProcess.start()
    
    time.sleep(2)
    runningVMs = subprocess.check_output('VBoxManage list runningvms', shell=True, stderr=subprocess.STDOUT)
    vmFound = '' if ( runningVMs == '' ) else subprocess.check_output('echo "'+ runningVMs +'" | grep "'+ vmName +'"', shell=True, stderr=subprocess.STDOUT)
    
    if( vmFound == '' ):
      print '"'+ vmName +'" has stopped.'
      msgProcess.terminate()
    else:
      stopVM(vmName, True)
    
  except subprocess.CalledProcessError as err:
    msgProcess.terminate()
    print "\n[ERROR] Couldn't stop '"+ vmName +"':"
    print err.output


def progressDots():
  while True:
    for dots in ['   ', '.   ', '.   ', '..  ', '..  ', '... ', '... ', '....', '....']: 
      yield dots


def spinningCursor():
  while True:
    for cursor in '|/—\\'.decode('utf8'): 
      yield cursor
  
if __name__ == "__main__":
  main(sys.argv[1:])
