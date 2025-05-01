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
                    composeDir = sh(
                        script: 'find . -name docker-compose.yml | head -n 1 | xargs dirname',
                        returnStdout: true
                    ).trim()
                    echo "Docker Compose files located in: ${composeDir}"
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir("${composeDir}") {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh '''
                                echo Logging in to AWS ECR...
                                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                            '''
                        }
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                dir("${composeDir}") {
                    sh 'docker compose build'
                }
            }
        }

        stage('Tag and Push Images to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir("${composeDir}") {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh '''
                                echo Tagging and pushing each image to ECR...

                                for SERVICE in $(docker compose config --services); do
                                    IMAGE=$(docker compose config | awk "/${SERVICE}:/{flag=1; next} /image:/{if(flag){print \$2; flag=0}}" | head -n1)
                                    if [ -z "$IMAGE" ]; then
                                        IMAGE="${SERVICE}:latest"
                                    fi

                                    ECR_IMAGE="${ECR_REGISTRY}/${SERVICE}:latest"
                                    echo "Tagging $IMAGE as $ECR_IMAGE"
                                    docker tag "$IMAGE" "$ECR_IMAGE" || echo "Image $IMAGE not found, skipping..."
                                    docker push "$ECR_IMAGE" || echo "Failed to push $ECR_IMAGE"
                                done
                            '''
                        }
                    }
                }
            }
        }

        stage('Cleanup Local Docker Images') {
            steps {
                sh '''
                    docker image prune -a -f
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
