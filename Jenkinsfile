pipeline {
    agent {
        label 'docker_agent_java'
    }

    environment {
        IMAGE_NAME = 'springbootapp'
        IMAGE_TAG = "$BUILD_ID"
        DOCKER_HOST = "socatnlb-b7d5a7433da1a660.elb.ap-south-1.amazonaws.com:80"
        DOCKER_REGISTRY = "730335239716.dkr.ecr.ap-south-1.amazonaws.com"
        DOCKER_NAMESPACE = "karthikb21"
        DOCKER_REPO = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"
        TASK_DEFINITION = "springbootapp_task_definition"
        DOCKER_CREDS_ID = 'docker_registry_creds'
        AWS_CREDS_ID = "aws_creds"
        ECS_CLUSTER = "DevCluster"
        ECS_SERVICE = "SpringBootApp"
        AWS_REGION = "ap-south-1"

    }
    stages{
        stage('Git Checkout'){
            steps{
                sh ''

                    echo ${params.Branch}
                ''
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
                    sh "docker --host ${DOCKER_HOST} build -t ${DOCKER_REPO}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Configure AWS CLI') {
            steps {
                script{
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: "${AWS_CREDS_ID}",
                        ]]) {
                            sh "aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID"
                            sh "aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY"
                            sh "aws configure set region ap-south-1"
                        }                }
            }

        }

        stage('Push Image to Registry') {
            steps{
                sh "aws ecr get-login-password --region ap-south-1 | docker --host ${DOCKER_HOST} login --username AWS --password-stdin ${DOCKER_REGISTRY}"
                sh "docker --host ${DOCKER_HOST} -D push ${DOCKER_REPO}:${IMAGE_TAG}"
            }
        }


        stage('Update Task Definition'){
            steps{
                script{
                    def taskDefinition = sh(script: 'aws ecs describe-task-definition --task-definition ${TASK_DEFINITION}', returnStdout: true).trim()
                    print(taskDefinition)


                    def taskDef = readJSON text: taskDefinition
                    def taskDefJson = taskDef.taskDefinition

                    taskDefJson.containerDefinitions[0].image = "${DOCKER_REPO}:${IMAGE_TAG}".toString()
                    
                    // Remove fields that cannot be included in new task definition
                    taskDefJson.remove('taskDefinitionArn')
                    taskDefJson.remove('revision')
                    taskDefJson.remove('status')
                    taskDefJson.remove('requiresAttributes')
                    taskDefJson.remove('compatibilities')
                    taskDefJson.remove('registeredAt')
                    taskDefJson.remove('registeredBy')

                    env.NEW_TASK_DEFINITION_JSON = writeJSON(json: taskDefJson, returnText: true)

                    echo "${NEW_TASK_DEFINITION_JSON}"

                    // Register new task definition

                    def newTaskDefinition = sh(script: "aws ecs register-task-definition --cli-input-json '${NEW_TASK_DEFINITION_JSON}'", returnStdout: true).trim();
                    def newtaskDef = readJSON text: newTaskDefinition
                    print(newtaskDef)
                    env.NEW_TASK_DEFINITION = newtaskDef.taskDefinition.taskDefinitionArn
                    echo "${NEW_TASK_DEFINITION}"
                }
            }
        }

        stage('Deploy Service'){
            steps{
                script{
                    sh "aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --task-definition ${NEW_TASK_DEFINITION} --region ${AWS_REGION} --desired-count=1 --force-new-deployment"
                                        // Wait for service stability
                    sh """
                        aws ecs wait services-stable \
                            --cluster ${ECS_CLUSTER} \
                            --services ${ECS_SERVICE} \
                            --region ${AWS_REGION}
                    """
                }
            }
        }
    }
    
        post {
            always {
                script {
                    sh "docker --host ${DOCKER_HOST} rmi ${DOCKER_REPO}:${IMAGE_TAG}"
                }
            }

            success{
                echo "Build Success"
            }
            failure {
                echo "Build Failed"
            }
        }        
    
}
