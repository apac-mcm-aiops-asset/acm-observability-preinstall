FROM quay.io/openshift/origin-cli:4.8

WORKDIR ~
COPY main.sh main.sh
RUN export PATH="~:$PATH"
RUN chmod +x main.sh 

CMD ["./main.sh"]