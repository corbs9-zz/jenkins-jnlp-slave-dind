def imageName = "midiapetala/petal_agent_build"
def dockerHost = "tcp://0.0.0.0:2375"

pipeline {
  agent {
    kubernetes {
      label 'jenkins-pod'
    }
  }
  stages {
    stage('Creating Release and Tagging') {
      when { 
        anyOf { 
          branch 'develop'; 
          branch 'master' 
        } 
      }
      steps {
        withCredentials([string(credentialsId: 'petala-gh-token', variable: 'TOKEN')]) {
          nodejs('NodeJS 14') {  
            sh 'npm install'               
            sh "GH_TOKEN=${TOKEN} node_modules/semantic-release/bin/semantic-release.js"
          }          
        }
      }
    }    
    stage('Build & Publish Docker Image') {
      steps {
        script {
          def TAG = sh(returnStdout: true, script: "git tag --sort version:refname | tail -1 | cut -c2-6").trim()
          def TAGA = sh(returnStdout: true, script: "git tag --sort version:refname | tail -1 | cut -c2-4").trim()
          def TAGB = sh(returnStdout: true, script: "git tag --sort version:refname | tail -1 | cut -c2-2").trim()

          def docker = tool 'Docker'

          sh "DOCKER_HOST=\"${dockerHost}\" ${docker}/bin/docker build -t ${imageName}:${TAG} -t ${imageName}:${TAGA} -t ${imageName}:${TAGB} -t ${imageName}:latest ."
          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh "DOCKER_HOST=\"${dockerHost}\" ${docker}/bin/docker login -p ${PASSWORD}  -u ${USERNAME} "
          }
          sh "DOCKER_HOST=\"${dockerHost}\" ${docker}/bin/docker push ${imageName}"
        }
      }
    }
  }
}