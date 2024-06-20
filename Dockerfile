FROM erlantfarias/ntp-server:1.0.0 

RUN service ntp start

# Expor a porta 123 para o tráfego NTP
EXPOSE 123/udp

# Comando para iniciar o serviço NTP em foreground
RUN ./ntpq_monitor.sh
#CMD ["ntpq", "-p"]
