import json

def writeJsonData(f_write, to_stop = 38294):
    f = open("data.json")

    data = json.load(f)

    useful_data = {}
    item_ids = []
    item_classes = []
    item_prices = {}

    f_write.write('\nINSERT INTO item (id, name, properties) VALUES \n')
    counter = 0

    for value in data:
        name = value['name'].replace("'", "")
        item_class = value['class']
        
        useful_data['itemId'] = value['itemId']
        useful_data['sellPrice'] = value['sellPrice']
        useful_data['quality']= value['quality']
        useful_data['itemLevel'] = value['itemLevel']
        useful_data['requiredLevel'] = value['requiredLevel']
        useful_data['slot'] = value['slot']
        
        json_data = json.dumps(useful_data)
        
        counter += 1
        if counter == to_stop + 1:
            f_write.write(f"('{useful_data['itemId']}', '{name}', '{json_data}'); \n")
            break
        else:
            f_write.write(f"('{useful_data['itemId']}', '{name}', '{json_data}'), \n")
            
        item_ids.append(useful_data['itemId'])
        item_prices[useful_data['itemId']] = useful_data['sellPrice']
        item_classes.append(item_class)
        
    f.close()
    
    return item_ids, item_classes, item_prices