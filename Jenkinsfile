pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '975050024946.dkr.ecr.us-east-1.amazonaws.com'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Manjyyot/SaleProject.git'
            }
        }

        stage('Locate Docker Compose Directory') {
            steps {
                script {
                    def composeDir = sh(
                        script: 'find . -name docker-compose.yml | head -n 1 | xargs dirname',
                        returnStdout: true
                    ).trim()
                    echo "Docker Compose files located in: ${composeDir}"
                    env.COMPOSE_DIR = composeDir
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                        echo "Logging in to AWS ECR..."
                        aws --version
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                dir("${env.COMPOSE_DIR}") {
                    sh '''
                        echo "Building and tagging images..."
                        docker compose build

                        echo "Tagging and pushing each image to ECR..."
                        for SERVICE in $(docker compose config --services); do
                            IMAGE_NAME="${ECR_REGISTRY}/${SERVICE}:latest"
                            docker tag ${SERVICE}:latest $IMAGE_NAME
                            docker push $IMAGE_NAME
                        done
                    '''
                }
            }
        }

        stage('Cleanup Local Docker Images') {
            steps {
                sh '''
                    echo "Cleaning up local Docker images..."
                    docker image prune -af
                '''
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Check the logs for more information.'
        }
        cleanup {
            cleanWs()
        }
    }
}
