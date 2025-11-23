# Automated VM Deployment with Startup Scripts (GCP)
**Projekt 6, Grupa 2**
- Kaja Latko
- Oliwia Spaleniak
- Oliwia Ankiewicz
- Zofia Kramer
- Katarzyna Szmagara

Celem projektu jest automatyzacja procesu wdrażania serwerów w chmurze Google Cloud Platform. Zamiast ręcznej konfiguracji każdej maszyny, wykorzystujemy podejście Infrastructure as Code (IaC).

## Użyte technologie
* Google Cloud Platform (Compute Engine)
* Bash (Startup Script)
* Linux (Debian/Ubuntu)
* Nginx

## Struktura plików
* `scripts/startup-script.sh` - Skrypt instalujący serwer WWW.
* `scripts/deploy-commands.sh` - Komendy gcloud użyte do stworzenia infrastruktury.
* `logs/` - Logi potwierdzające uruchomienie usług.

## Skrypt Startowy `(startup-script.sh)`
plik tekstowy, który serwer wykonuje automatycznie przy pierwszym uruchomieniu.

Zawartość skryptu użytego w projekcie:
```bash
#!/bin/bash
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
HOSTNAME=$(hostname)
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(275, 200, 200);'> <h1>Super, udalo nam się stworzyc projekt! </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p>Pozdrawiamy, Zespol projektu 6, grupa 2 :)</p> </body></html>" | sudo tee /var/www/html/index.html
```
* Instaluje narzędzie telnet oraz serwer WWW Nginx.
* Generuje plik index.html z unikalnym kolorem tła.
* Wypisuje na stronie nazwę hosta (HOSTNAME) oraz adres IP maszyny, co pozwala odróżnić serwery od siebie.

## Tworzenie Szablonu (Instance Template)
Szablon instancji definiuje parametry techniczne serwera.

Parametry szablonu:
* Machine Type: e2-micro
* Region: us-central1
* Tagi sieciowe: http-server, allow-http, allow-https, allow-ssh-from-iap, allow-icmp
* Metadata: Załączony plik startup-script.sh

Komenda użyta do utworzenia szablonu
```bash
gcloud compute instance-templates create mig-template-p62-v2 \
    --machine-type=e2-micro \
    --network-interface=network=default,network-tier=PREMIUM \
    --tags=allow-http,allow-https,allow-ssh-from-iap,allow-icmp  \
    --metadata-from-file=startup-script=startupscriptP62.sh \
    --region=us-central1
```

## Managed Instance Group (MIG)
MIG to grupa instancji utworzona na podstawie szablonu.
Utworzenie grupy 3 instancji:
```bash
gcloud compute instance-groups managed create mig-p62 \
    --size=3 \
    --template=mig-template-p62-v2 \
    --zone=us-central1-c
```
* Powołuje 3 maszyny wirtualne.
* Na każdej z nich wykonuje startup-script.sh.
* Uruchamia serwer Nginx.

## Firewall (Zabezpieczenia)
| Tag / Port | Protokół | Opis |
| :--- | :--- | :--- |
| **80** | HTTP | (`allow-http`) Pozwala na wyświetlenie strony WWW w przeglądarce. |
| **443** | HTTPS | (`allow-https`) Obsługa szyfrowanego ruchu. |
| **22** | SSH (IAP) | (`allow-ssh-from-iap`) Umożliwia bezpieczne logowanie. |
| **ICMP** | Ping | (`allow-icmp`) Pozwala na sprawdzanie dostępności serwera. |
