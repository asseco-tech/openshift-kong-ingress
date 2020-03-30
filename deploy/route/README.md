# Skrypty instalacyjne Kong Routes

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
 - templates/* - szablony obiektów Kong do utworzenia route'ów
 - scripts/yaml.sh - parser YAML na licencji MIT ( [bash-yaml](https://github.com/jasperes/bash-yaml) )
