#!/bin/bash

# Inicia o serviço NTP
service ntp start

# Loop infinito
while true
do
  # Executa o comando ntpq -p
  ntpq -p

  # Aguarda por um intervalo mínimo de 0.1 segundo (100ms)
  sleep 0.1
done