pipeline {
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

        stage('Get Podman'){
            steps{
                sh "apt-get install podman -y"
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    
                    sh "sudo podman build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }


        stage('Login to Docker Registry') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | podman login -u $DOCKER_USER --password-stdin ${DOCKER_REGISTRY}"
                    }
                }
            }
        }
    }    
    
}
