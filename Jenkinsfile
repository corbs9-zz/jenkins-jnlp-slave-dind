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
          branch 'develop';  
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

          sh "docker build --network host -t ${imageName}:${TAG} -t ${imageName}:${TAGA} -t ${imageName}:${TAGB} -t ${imageName}:latest ."
          withCredentials([usernamePassword(credentialsId: 'dockerhub-at', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            sh "docker login -p ${PASSWORD}  -u ${USERNAME} "
          }
          sh "docker push ${imageName}"
        }
      }
    }
  }
}