pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '975050024946.dkr.ecr.us-east-1.amazonaws.com/saleprojects'
        COMPOSE_PROJECT_NAME = 'saleproject'
    }

    stages {
        stage('Checkout Source') {
            steps {
                git 'https://github.com/Manjyyot/SaleProject.git'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                        aws --version
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Build and Tag Docker Images') {
            steps {
                sh '''
                    docker-compose build
                    docker images

                    # Tag built images
                    docker tag saleproject_frontend $ECR_REPO:frontend-latest
                    docker tag saleproject_backend $ECR_REPO:backend-latest
                '''
            }
        }

        stage('Local Testing') {
            steps {
                sh '''
                    docker-compose up -d
                    sleep 10
                    docker ps
                    docker-compose ps
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    docker push $ECR_REPO:frontend-latest
                    docker push $ECR_REPO:backend-latest
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker-compose down'
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
    }
}
