#!/bin/bash

# Christophe Bassette
# 23/05/2025
# Testé sur macOS 13 / macOS 14 / macOS 15
# v2.0
# Basculer automatiquement entre Ethernet et Wi-Fi


# TEMPORISATION (pour laisser le temps au réseau de monter si lancé au boot)
MAX_WAIT=30
COUNT=0
echo "Attente de la disponibilité du service réseau (max $MAX_WAIT sec)..."

while [ $COUNT -lt $MAX_WAIT ]; do
    # On considère le réseau prêt si au moins une interface a une IP
    READY=$(ifconfig | grep "inet " | grep -v "127.0.0.1")
    if [ -n "$READY" ]; then
        echo "Interface réseau détectée."
        break
    fi
    sleep 1
    COUNT=$((COUNT + 1))
done

# Récupération des interfaces
WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
ETH_INTERFACE=$(networksetup -listallhardwareports | awk '/Ethernet/{getline; print $2}' | head -n 1)

if [ -z "$WIFI_INTERFACE" ] || [ -z "$ETH_INTERFACE" ]; then
    echo "Interfaces introuvables."
    exit 1
fi

echo "Wi-Fi : $WIFI_INTERFACE | Ethernet : $ETH_INTERFACE"

# Vérifie si Ethernet a une IP
ETH_IP=$(ipconfig getifaddr "$ETH_INTERFACE")
echo "Adresse IP Ethernet : ${ETH_IP:-Aucune}"

# Tester la connectivité réseau via ping
check_connectivity() {
    ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1
    return $?
}

# Lecture état Wi-Fi
WIFI_STATUS=$(networksetup -getairportpower "$WIFI_INTERFACE" | awk '{print $4}')
echo "État actuel du Wi-Fi : $WIFI_STATUS"

# Logique principale
if [ -n "$ETH_IP" ]; then
    echo "IP détectée sur Ethernet. Vérification de la connectivité..."
    if check_connectivity; then
        echo "Connexion Ethernet fonctionnelle."
        if [ "$WIFI_STATUS" = "On" ]; then
            echo "Désactivation du Wi-Fi..."
            networksetup -setairportpower "$WIFI_INTERFACE" off
        else
            echo "Wi-Fi déjà désactivé."
        fi
    else
        echo "Pas de connectivité réseau via Ethernet malgré IP."
        if [ "$WIFI_STATUS" = "Off" ]; then
            echo "Activation du Wi-Fi..."
            networksetup -setairportpower "$WIFI_INTERFACE" on
        else
            echo "Wi-Fi déjà activé."
        fi
    fi
else
    echo "Pas d'IP Ethernet. Activation du Wi-Fi..."
    if [ "$WIFI_STATUS" = "Off" ]; then
        networksetup -setairportpower "$WIFI_INTERFACE" on
        echo "Wi-Fi activé."
    else
        echo "Wi-Fi déjà activé."
    fi
fi
