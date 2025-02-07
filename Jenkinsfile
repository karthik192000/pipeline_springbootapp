pipeline {
    agent {
        label 'docker_agent_java'
    }

    environment {
        IMAGE_NAME = 'springbootapp'
        IMAGE_TAG = "$BUILD_ID"
        DOCKER_HOST = "socatnlb-b20e4b1d9c152ab5.elb.ap-south-1.amazonaws.com:80"
        DOCKER_REGISTRY = "730335239716.dkr.ecr.ap-south-1.amazonaws.com"
        DOCKER_NAMESPACE = "karthikb21"
        DOCKER_REPO = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"
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
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker --host ${DOCKER_HOST} build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Install AWS CLI') {
            steps {
                sh '''
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    apt-get install -y unzip
                    unzip awscliv2.zip
                    ./aws/install
                    aws --version
                '''
            }

        }


        // stage('Login to Docker Registry') {
        //     steps {
        //         script {
        //             withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        //                 sh "echo $DOCKER_PASS | docker --host socatnlb-0ea57a52100e6e75.elb.ap-south-1.amazonaws.com:2376 login -u $DOCKER_USER --password-stdin ${DOCKER_REGISTRY}"
        //             }
        //         }
        //     }
        // }


        stage('Push Image to Registry') {
            // steps {
            //     script {
            //         withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            //             sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin ${DOCKER_REGISTRY}"
            //         }
            //     }
            // }

            steps{

                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "docker logout"
                        sh "echo $DOCKER_PASS | aws ecr get-login-password --region ap-south-1 | docker --host ${DOCKER_HOST} login --username AWS --password-stdin ${DOCKER_REGISTRY}"
                        sh "docker --host ${DOCKER_HOST} -D push ${DOCKER_REPO}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Clean up') {
            steps{
            sh "docker --host ${DOCKER_HOST} rmi ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }    
    
}
