pipeline {
    agent any

    environment {
        AWS_REGION      = 'us-east-1'
        AWS_ACCOUNT_ID  = '975050024946'
        ECR_REPOSITORY  = 'saleprojects'
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
        ECR_REGISTRY    = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI       = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
        CONTAINER_NAME  = "saleproject-test"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Manjyyot/SaleProject.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPOSITORY}:${IMAGE_TAG}")
                }
            }
        }

        stage('Local Container Test') {
            steps {
                script {
                    // Run container in detached mode
                    sh """
                        docker run -d --rm --name ${CONTAINER_NAME} -p 8080:8080 ${ECR_REPOSITORY}:${IMAGE_TAG}
                        sleep 10
                        docker ps
                        docker logs ${CONTAINER_NAME}
                    """
                }
            }
        }

        stage('Validate Container Health') {
            steps {
                script {
                    def containerStatus = sh(script: "docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME}", returnStdout: true).trim()
                    if (containerStatus != "true") {
                        error "Container did not start correctly. Aborting."
                    }
                }
            }
        }

        stage('Stop Test Container') {
            steps {
                sh "docker stop ${CONTAINER_NAME} || true"
            }
        }

        stage('Authenticate to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    """
                }
            }
        }

        stage('Tag and Push to ECR') {
            steps {
                sh """
                    docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${IMAGE_URI}
                    docker push ${IMAGE_URI}
                """
            }
        }
    }

    post {
        always {
            sh 'docker container prune -f'
            sh 'docker image prune -af'
        }
        success {
            echo "✅ Image ${IMAGE_URI} built and pushed to ECR successfully."
        }
        failure {
            echo "❌ Build failed. Check logs."
        }
    }
}
