#1. Wgrywamy plik .sh w Cloud Shell Terminal


#2. Ustawiamy zmienne
PROJECT_ID="graceful-fin-472315-j2" 
REGION="us-central1"
ZONE="us-central1-c"


# 3. Stworzenie Instance Template
gcloud config set project $PROJECT_ID
gcloud config set compute/zone $ZONE

gcloud compute instance-templates create mig-template-p62 \
    --machine-type=e2-micro \
    --network-interface=network=default,network-tier=PREMIUM \
    --tags=http-server \
    --metadata-from-file=startup-script=startupscriptP62.sh \
    --region=$REGION


# 4. Utworzenie MIG z 3 instancjami w ustalonej strefie
gcloud compute instance-groups managed create mig-p62 \
    --size=3 \
    --template=mig-template-p62 \
    --zone=$ZONE

#-----------------------------------------UPDATE--------------------------------------------
# 1. Ustawienie zmiennych 
PROJECT_ID="graceful-fin-472315-j2" 

# 2. Utworzenie nowego Instance Template (v2) z tagami
gcloud compute instance-templates create mig-template-p62-v2 \
    --machine-type=e2-micro \
    --network-interface=network=default,network-tier=PREMIUM \
    --tags=allow-http,allow-https,allow-ssh-from-iap,allow-icmp  \
    --metadata-from-file=startup-script=startupscriptP62.sh \
    --region=us-central1

# 3. Aktualizacja MIG do wersji V2
gcloud compute instance-groups managed rolling-action start-update mig-p62 \
    --version template=mig-template-p62-v2 \
    --zone=us-central1-c \
    --max-unavailable=1 \
    --max-surge=1
