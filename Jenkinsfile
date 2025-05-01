pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '975050024946.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO_PREFIX = 'saleprojects'
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
                                aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR_REGISTRY}
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
                script {
                    // Map actual built image names to target ECR repo names
                    def imageMap = [
                        "salespipeline-careerpath"     : "careerpath",
                        "salespipeline-frontend"       : "frontend",
                        "bitnami/mongodb-exporter"     : "mongodb-exporter",
                        "prom/prometheus"              : "prometheus"
                    ]

                    for (builtName in imageMap.keySet()) {
                        def ecrName = imageMap[builtName]
                        def fullEcrTag = "${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${ecrName}:latest"

                        echo "➡️ Checking image: ${builtName}:latest"

                        def exists = sh(script: "docker images -q ${builtName}:latest", returnStdout: true).trim()
                        if (exists) {
                            sh "docker tag ${builtName}:latest ${fullEcrTag}"
                            sh "docker push ${fullEcrTag}"
                        } else {
                            echo "⚠️ Image ${builtName}:latest not found, skipping push."
                        }
                    }
                }
            }
        }

        stage('Cleanup Local Docker Images') {
            steps {
                sh 'docker image prune -a -f'
            }
        }
    }

    post {
        always {
            echo "Pipeline completed."
            cleanWs()
        }
    }
}
