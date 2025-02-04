pipeline {

    tools{
        docker
    }
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
                docker login -u bankapurkarthik@gmail.com -p Gennext@2023
                docker build -t karthik192000/springbootapp .
                docker push karthik192000/springbootapp
                '''
            }
        }
    }    
    
}
