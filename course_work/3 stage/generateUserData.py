import bcrypt 
import random
from random_username.generate import generate_username
import time
from password_generator import PasswordGenerator

secret = "B6E5061FADAD40CCAEBDD0F4B3EB3DEE3F4FCE86695FA0076BA9E0A894A53140"
nicknames = set()

def generateUsername():
    nickname = generate_username(1)[0] + "@email.ru"
    while nickname in nicknames:
        nickname = generate_username(1)[0] + "@email.ru"
    nicknames.add(nickname)
    return nickname

def generatePassword(username):
    pwo = PasswordGenerator()
    pwo.minlen = 8
    password = pwo.generate()
    print(f"username: {username} password: {password}")
    password = password.encode('utf-8')
    psw = bcrypt.hashpw(password, 
                         bytes("$2b$12$mCpUyrRK5eg6LXqUoLEIBe", 'utf-8'))
    return psw

def generateBirthDate():
    return random_date("1980-1-1", "2000-12-31", '%Y-%m-%d', random.random())

def generateRegistrationDate():
    return random_date("2020-1-1", "2023-12-31", '%Y-%m-%d', random.random())

def _str_time_prop(start, end, time_format, prop):
    stime = time.mktime(time.strptime(start, time_format))
    etime = time.mktime(time.strptime(end, time_format))

    ptime = stime + prop * (etime - stime)

    return time.strftime(time_format, time.localtime(ptime))

def random_date(start, end, template, prop):
    return _str_time_prop(start, end, template, prop)