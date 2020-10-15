#!/bin/bash
dockerpull()
{
  echo "Deploying Elasticsearch Container"
  docker pull docker.elastic.co/elasticsearch/elasticsearch:7.9.2 > /dev/null 2>&1
  docker run --name elasticsearch -d -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.9.2 > /dev/null 2>&1
  sleep 30
  echo "Elasticsearch Container deployed"
  echo " "
  echo "!!!!!health Check status of ES Cluster!!!!!"
  echo " "
  curl -X GET "localhost:9200/_cat/nodes?v&pretty"
}

dockerinstall()

{
    echo " "
    echo "Please Wait...Installing Docker"
    sudo apt-get update > /dev/null 2>&1
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null 2>&1
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y > /dev/null 2>&1
    sudo systemctl start docker > /dev/null 2>&1
    echo "Docker installed"
    echo " "
    dockerpull

}

if [ -x "$(command -v docker)" ]; then
     echo " "
     echo "Docker is installed"

     container_name=elasticsearch

     sudo docker ps | grep "${container_name}" > /dev/null 2>&1

      if [ $? = 0 ]; then

         echo "exists conatiner $container_name"
         echo " "
         echo "!!!!!health Check status of ES Cluster!!!!!"
         curl -X GET "localhost:9200/_cat/nodes?v&pretty"

      else
          echo "does not exist"
          dockerpull
      fi

else
    dockerinstall
fi





