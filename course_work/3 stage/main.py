from generateUserData import *
from jsonItem import writeJsonData

f = open("insert.sql", "w")

start = time.time()

counter = 10 # [1; 3800] && counter % 5 == 0
koefficient = 1000 # [1; 10]

user_logins = []

f.write('INSERT INTO _user (login, birth_date, registration_date) VALUES \n')
for i in range(counter):
    username = generateUsername()
    birthdate = generateBirthDate()
    registrationdate = generateRegistrationDate()
    
    if i == counter - 1:
        f.write(f"('{username}', '{birthdate}', '{registrationdate}'); \n")
    else:
        f.write(f"('{username}', '{birthdate}', '{registrationdate}'), \n")
        
    user_logins.append(username)
    
print('user succesfully insert')

f.write('\nINSERT INTO password (user_login, password) VALUES \n')
for i in range(counter):
    password = str(generatePassword()).replace("b", "", 1).replace("'", "")
    username = user_logins[i]
    
    if i == counter - 1:
        f.write(f"('{username}', '{password}'); \n")
    else:   
        f.write(f"('{username}', '{password}'), \n")
        
print('password succesfully insert')        

item_ids, item_classes, item_prices = writeJsonData(f, counter * koefficient)

print("item succesfully insert")

already_favourite_id = {}

f.write('\nINSERT INTO favourite (user_login, item_id) VALUES \n')
for i in range(int (counter * (koefficient / 5))):
    username = user_logins[random.randint(0, counter - 1)]
    item_id = item_ids[random.randint(0, counter * koefficient - 1)]
    
    if username not in already_favourite_id:
        already_favourite_id[username] = set()
    
    while (item_id in already_favourite_id[username]):
        item_id = item_ids[random.randint(0, counter * koefficient - 1)]
    already_favourite_id[username].add(item_id)
    
    if i == (koefficient / 5) * counter - 1:
        f.write(f"('{username}', '{item_id}'); \n")
    else:
        f.write(f"('{username}', '{item_id}'), \n")

print('favourite succesfully insert')

f.write('\nINSERT INTO item_category (item_id, category) VALUES \n')
for i in range(counter * koefficient):
    item_class = item_classes[i]
    item_id = item_ids[i]
    
    if i == koefficient * counter - 1:
        f.write(f"('{item_id}', '{item_class}'); \n")
    else:
        f.write(f"('{item_id}', '{item_class}'), \n")

item_lot_ids = []

print('item_category succesfully insert')

f.write('\nINSERT INTO lot (user_login, item_id) VALUES \n')
for i in range(int (counter * (koefficient / 5))):
    username = user_logins[random.randint(0, counter - 1)]
    if i < 100:
        item_id = 25
    else:
        item_id = item_ids[random.randint(0, counter * koefficient - 1)]  
    
    item_lot_ids.append(item_id)
    
    if i == (koefficient / 5) * counter - 1:
        f.write(f"('{username}', '{item_id}'); \n")
    else:
        f.write(f"('{username}', '{item_id}'), \n")
        
print('lot succesfully insert')

expired = []
active = []

f.write('\nINSERT INTO lot_cost_information (cost_start, cost_current, cost_buy) VALUES \n')
for i in range(int (counter * (koefficient / 5))):
    item_lot_id = item_lot_ids[i]
    sell_price = item_prices[item_lot_id]
    
    if (sell_price == 0):
        cost_buy = random.randint(sell_price + 1, 20)
        cost_current = random.randint(sell_price, cost_buy)
        cost_start = random.randint(sell_price, cost_current)
    else:    
        cost_buy = random.randint(sell_price + 1, 2 * sell_price)
        cost_current = random.randint(sell_price, cost_buy)
        cost_start = random.randint(sell_price, cost_current)
    
    if (random.random() <= 0.2): # 20% expired
        cost_buy = cost_start
        expired.append(True)
        active.append(False)
    else:
        if (random.random() <= 0.3): # 30% active
            cost_buy = ''
            active.append(True)
        else:
            active.append(False)
        expired.append(False)
    
    if i == (koefficient / 5) * counter - 1:
        if cost_buy == '':
            f.write(f"('{cost_start}', '{cost_current}', NULL); \n")
        else:
            f.write(f"('{cost_start}', '{cost_current}', '{cost_buy}'); \n")
    else:
        if cost_buy == '':
            f.write(f"('{cost_start}', '{cost_current}', NULL), \n")
        else:
            f.write(f"('{cost_start}', '{cost_current}', '{cost_buy}'), \n")


print('lot_cost_information succesfully insert')

f.write('\nINSERT INTO lot_time_information (time_start, time_end, time_finish) VALUES \n')
for i in range(int (counter * (koefficient / 5))):
    time_format = '%Y-%m-%d %H:%M:%S'
    
    time_start = random_date("2023-12-1 00:00:00", "2023-12-31 23:59:59", time_format, random.random())
    time_start_seconds = time.mktime(time.strptime(time_start, time_format))
    
    duration_lot_seconds = random.choice([2, 8, 24]) * 60 * 60
    
    time_end_seconds = time_start_seconds + duration_lot_seconds
    time_end = time.strftime(time_format, time.localtime(time_end_seconds))
    
    if expired[i]:
        time_finish = time_end
    elif active[i]:
        time_finish = ''
    else:
        time_finish = random_date(time_start, time_end, time_format, random.random())
        
    if i == (koefficient / 5) * counter - 1:
        if time_finish == '':
            f.write(f"('{time_start}', '{time_end}', NULL); \n")
        else:
            f.write(f"('{time_start}', '{time_end}', '{time_finish}'); \n")
    else:
        if time_finish == '':
            f.write(f"('{time_start}', '{time_end}', NULL), \n")
        else:
            f.write(f"('{time_start}', '{time_end}', '{time_finish}'), \n")

print('lot_time_information succesfully insert')

f.write('\nINSERT INTO lot_status_information (status) VALUES \n')
for i in range(int (counter * (koefficient / 5))):
    status_enum = ['EXPIRED', 'ACTIVE', 'SOLD']
    
    if expired[i]:
        status = status_enum[0]
    elif active[i]:
        status = status_enum[1]
    else:
        status = status_enum[2]
    
    if i == (koefficient / 5) * counter - 1:
        f.write(f"('{status}'); \n")
    else:
        f.write(f"('{status}'), \n")

print('lot_status_information succesfully insert')

f.write('\nINSERT INTO dependency (item_first_id, item_second_id) VALUES \n')
for i in range(counter):
    item_first_id = item_ids[random.randint(0, counter * koefficient - 1)]
    item_second_id = item_ids[random.randint(0, counter * koefficient - 1)]

    while (item_first_id == item_second_id):
        item_second_id = item_ids[random.randint(0, counter * koefficient - 1)]
        
    if i == counter - 1:
        f.write(f"('{item_first_id}', '{item_second_id}'); \n")
    else:
        f.write(f"('{item_first_id}', '{item_second_id}'), \n")

print('dependency succesfully insert')

end = time.time()

print(f'total time: {end - start}s, {(end - start) / 60}m')

