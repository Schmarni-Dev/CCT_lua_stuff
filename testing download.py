import requests
import os

def main(u,r,b,f: str):
    nf = f.replace(" ", "%20")
    path = os.path.dirname(os.path.realpath(__file__))

    r = requests.get(f"https://raw.githubusercontent.com/{u}/{r}/{b}/{nf}")

    with open(os.path.join(path,f'temp\\{f}'),"wb") as f:
       f.write(r.content)
    

if __name__ == '__main__':
    main("Schmarni-Dev","CCT_lua_stuff","main","testing download.py")