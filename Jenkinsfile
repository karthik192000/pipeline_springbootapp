pipeline {

    tools {
        docker 
    }
    agent {
        label 'docker_agent_java'
    }

    environment {
        IMAGE_NAME = 'springbootapp'
        IMAGE_TAG = "$BUILD_ID"
        DOCKER_REGISTRY = 'docker.io/karthikb21'
        DOCKER_CREDS_ID = 'docker_registry_creds'
    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'master', url:'https://github.com/karthik192000/SpringBootApp.git'
            }
        }
        stage ('Maven Build Jar') {
            steps {

                sh '''

                mvn clean install
                 '''

            }
        }
        stage('Create Docker Image'){
            steps{

                
                withCredentials([usernamePassword(credentialsId:"$DOCKER_CREDS_ID",usernameVariable: "$DOCKER_USER", passwordVariable: "$DOCKER_PASS")])
                sh '''
                
                docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"
                docker build -t karthikb21/springbootapp .
                 '''
        
            }
        }
    }    
    
}
