FROM rocker/verse:3.5.1
RUN apt-get update -qq && apt-get -y --no-install-recommends install libsasl2-dev
## Install additional packages required for the project
RUN Rscript -e 'install.packages("emmeans")'
RUN Rscript -e 'install.packages("mice")'
RUN Rscript -e 'install.packages("quantreg")'
RUN Rscript -e 'install.packages("htmlTable")'
RUN Rscript -e 'install.packages("randomForest")'
RUN Rscript -e 'install.packages("survey")'
RUN Rscript -e 'install.packages("tableone")'
RUN Rscript -e 'install.packages("Matching")'
## Create yourself as a user and create a directory for the project
ENV USER=jinj40
RUN useradd $USER
RUN mkdir -p /home/$USER/project/
## Grab my r studio settings file
COPY ./env/rstudio-settings  /home/$USER/.rstudio
RUN chmod -R 777 /home/$USER/.rstudio
## Install local project package
RUN mkdir /home/$USER/temp  
COPY ./NAMESPACE ./LICENSE ./DESCRIPTION /home/$USER/temp/
COPY ./R /home/$USER/temp/R
COPY ./man /home/$USER/temp/man
RUN cd /home/$USER/temp/; Rscript -e "devtools::document() ; devtools::install()"
## Setup flag for makefile to know if it is running on laptop or docker container
ENV CONTAINER=DOCKER-R
RUN echo "CONTAINER=$CONTAINER" >> /usr/local/lib/R/etc/Renviron
COPY userconf.sh /etc/cont-init.d/userconf
WORKDIR /home/$USER/project/
CMD ["/init"]
