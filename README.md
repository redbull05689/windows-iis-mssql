```
vagrant up
vagrant rdp
vagrant halt
vagrant destroy -f
```

###CREATE PRJ-Arxspan-assay-module folder and PUT ASP folder inside it


SAPWD="#SAPassword!"

###Bake and publish
```
vagrant package --output 2008r2.box
vagrant cloud publish redbull05689/2008r2 0.1 virtualbox 2008r2.box
```
