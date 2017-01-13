import os
os.mkdir("Classes")
os.chdir("Classes")

for i in ['Controller', 'Model', 'Util', 'Vendor', 'View', 'ViewModel']:
    os.mkdir(i)
