import re
import os

re_modname = re.compile(r'module ([A-Za-z0-9_]+)\(')
verilator = 'verilator -Wall --exe verilator/sim.cpp --Mdir build -Iinclude'
make_cmd = 'make -C build'

def detect_dir():
  ans = ''
  for r, d, f in os.walk('../src'):
    for i in f:
      if i.endswith('.v'):
        if not d:
          ans += ' -I' + r
        else:
          for name in d:
            ans += ' -I' + os.path.join(r, name)
        break
  return ans

def get_mod_name(file):
  with open(file) as f:
    ans = re_modname.findall(f.read())
    return ans[0]

def compile(file, mod_name):
  cmd = f' {verilator} --cc {file} -CFLAGS "-DMODULE_NAME=V{mod_name}"'
  if os.system(cmd):
    exit(1)

def make(mod_name):
  cmd = f'{make_cmd} -f V{mod_name}.mk'
  if os.system(cmd):
    exit(1)

def run(mod_name):
  cmd = f'build/V{mod_name}'
  if os.system(cmd):
    exit(1)

if __name__ == '__main__':
  # read file name
  if len(os.sys.argv) != 2:
    print('invalid file name')
    exit(1)
  file = os.path.abspath(os.sys.argv[1])
  # change current working directory
  os.chdir(os.path.dirname(os.path.abspath(__file__)))
  # compile and run
  mod_name = get_mod_name(file)
  verilator += detect_dir()
  compile(file, mod_name)
  make(mod_name)
  run(mod_name)
