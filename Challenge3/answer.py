object = {'x': {'y': {'z': 'c'}}}
key = 'x/y/z'

def get_value(value, key):
    keys = key.split('/')
    for key in keys:
        value = value.pop(key)
    return value


print ("The value obtained using the function is :", get_value(object, key))