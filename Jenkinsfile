def remoteServer = [:]
  remoteServer.name          = 'python-app'
  remoteServer.fileTransfer  = 'scp'
  remoteServer.allowAnyHosts = true
  remoteServer.retryCount    = 3
  remoteServer.retryWaitSec  = 3

pipeline{
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: "5"))
    disableConcurrentBuilds()
    timeout(time: 10, unit: "MINUTES")
  }

  environment {
    NOMBRE_PROYECTO         = "hola-mundo"
    DOCKER_REGISTRY      = credentials('docker-registry')
    SERVER_DEPLOYMENT_IP = credentials('server-deployment-ip')
    DEPLOYMENT_RUTA      = "~/proyectos/${NOMBRE_PROYECTO}"
  }

  stages {
    stage("Checkout Code") {
      steps {
        checkout scm
      }
    }

    stage("Construccion Dockerfile") {
      steps {
        echo "========Creando Dockerfile========"
        script {
          pythonImage = docker.build("${NOMBRE_PROYECTO}:${env.BUILD_NUMBER}", "-f Dockerfile .")
        }
      }
    }

    stage("Analisis de Codigo") {
      steps {
        echo "========Analizando Codigo========"
        sh "sonar-scanner -Dproject.settings=sonar-project.properties"
      }
    }

    stage("Backup de la Imagen Docker al Registry") {
      steps {
        echo "========Cargando Backup Dockerfile al Registry========"
        script {
          docker.withRegistry("https://${DOCKER_REGISTRY}") {
            docker.image("${NOMBRE_PROYECTO}:${env.BUILD_NUMBER}").push()
          }
        }
      }
    }

    stage("Despliegue de la Aplicacion") {
      steps {
        script {
          sh "grep \"${SERVER_DEPLOYMENT_IP}\" ~/.ssh/known_hosts > /dev/null || (mkdir -p ~/.ssh && ssh-keyscan -t rsa ${SERVER_DEPLOYMENT_IP} >> ~/.ssh/known_hosts)"
          withCredentials([sshUserPrivateKey(credentialsId: 'ssh-ubuntu-python', keyFileVariable: 'identity', passphraseVariable: '', usernameVariable: 'userName')]) {
            remoteServer.host         = "${SERVER_DEPLOYMENT_IP}"
            remoteServer.user         = userName
            remoteServer.identityFile = identity
            sshCommand remote: remoteServer, command: "mkdir -p ${DEPLOYMENT_RUTA}"
            sshCommand remote: remoteServer, command: "docker run -d ${PROJECT_NAME}:${env.BUILD_NUMBER}"
          }
        }
      }
    }
  }
}
