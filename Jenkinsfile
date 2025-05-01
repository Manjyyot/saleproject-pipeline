pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '975050024946.dkr.ecr.us-east-1.amazonaws.com/saleprojects'
        COMPOSE_PROJECT_NAME = 'saleproject'
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
                        script: 'find . -name "docker-compose.yml" | head -n 1 | xargs dirname',
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
                    credentialsId: 'aws-jenkins-creds'
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
                dir(env.COMPOSE_DIR) {
                    sh '''
                        docker-compose build
                        docker images

                        docker tag saleproject_frontend $ECR_REPO:frontend-latest
                        docker tag saleproject_backend $ECR_REPO:backend-latest
                    '''
                }
            }
        }

        stage('Local Testing') {
            steps {
                dir(env.COMPOSE_DIR) {
                    sh '''
                        docker-compose up -d
                        sleep 10
                        docker ps
                        docker-compose ps
                    '''
                }
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

        stage('Cleanup Docker Compose') {
            steps {
                dir(env.COMPOSE_DIR) {
                    sh 'docker-compose down'
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Check logs.'
        }
        cleanup {
            cleanWs()
            sh 'docker system prune -f'
        }
    }
}
