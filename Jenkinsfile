def imageName = "aquelatecnologia/jenkins-jnlp-slave-dind"

pipeline {
  agent {
    kubernetes {
      label 'jenkins-pod'
    }
  }
  stages {
    stage('Creating Release and Tagging') {
      when { 
          branch 'master';  
      }
      steps {
        withCredentials([string(credentialsId: 'petala-gh-token', variable: 'TOKEN')]) {
          sh 'npm install'               
          sh "GH_TOKEN=${TOKEN} node_modules/semantic-release/bin/semantic-release.js"
        }
      }
    }    
    stage('Build & Publish Docker Image') {
      when { 
          branch 'master';  
      }
      steps {
        script {
          sh "docker build --network host -t ${imageName}:latest ."
          withCredentials([usernamePassword(credentialsId: 'dockerhub-at', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh "docker login -p ${PASSWORD}  -u ${USERNAME} "
          }
          sh "docker push ${imageName}"
        }
      }
    }
  }
}