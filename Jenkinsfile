pipeline {

    agent {
        label 'docker_agent_java'
    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'master', url:'https://github.com/karthik192000/SpringBootApp.git'
            }
        }
        stage ('Build'){
            steps{
                sh '''
                mvn clean install
                '''
            }
        }
        stage('Create Docker Image'){
            steps{
                sh '''
                sudo apt-get update -y apt-get install docker -y
                docker build -t springbootapp .
                '''
            }
        }
    }    
    
}
