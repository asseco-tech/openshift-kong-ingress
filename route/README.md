# Skrypty instalacyjne Kong Route Template

Konfiguracja:  
```
../configure.env
kong-routes.yaml
```

Wykonanie instalacji:  
```
./install.sh
```


Usunięcie obiektów:  
```
./install.sh delete
```

## Opis plików
 - install.sh - główny skrypt uruchomieniowy
 - kong-routes.yaml - konfiguracja reguł dla route'ów
 - kong-route-template.yaml - szablon obiektów Kong do utworzenia jednego route
 - kong-plugins-template.yaml - pluginy globalne aplikowane do wielu route'ów
 - yaml.sh - parser YAML na licencji MIT ( [bash-yaml](https://github.com/jasperes/bash-yaml) )
