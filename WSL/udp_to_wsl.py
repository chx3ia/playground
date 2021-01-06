"""
A python program sends 'Hello World' to the WSL with port 8888.
"""
import socket
from subprocess import run, PIPE
import re

PORT = 8888
MESSAGE = 'Hello World'

wsl2_ip = re.search('\sinet ((?:\d+\.){3}\d+)/', run('wsl -e ip -4 addr show dev eth0'.split(), stdout=PIPE, encoding='utf8', check=True).stdout)[1]
print('sending ' + MESSAGE + ' to ' + wsl2_ip)
with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
    s.connect((wsl2_ip, PORT))
    print(s.send(MESSAGE))
