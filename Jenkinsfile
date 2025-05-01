pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '975050024946.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO = 'saleprojects'
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
                    echo "Docker Compose directory: ${composeDir}"
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
                    def images = [
                        "prometheus",
                        "grafana",
                        "mongodb_exporter",
                        "careerpath",
                        "frontend"
                    ]

                    for (image in images) {
                        def localTag = "salespipeline-${image}:latest"
                        def ecrTag = "${ECR_REGISTRY}/${ECR_REPO}:${image}"

                        def imageExists = sh(
                            script: "docker images -q ${localTag}",
                            returnStdout: true
                        ).trim()

                        if (imageExists) {
                            echo "📦 Pushing ${localTag} to ${ecrTag}"
                            sh """
                                docker tag ${localTag} ${ecrTag}
                                docker push ${ecrTag}
                            """
                        } else {
                            echo "⚠️ Skipping ${localTag} — image not found locally."
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
            echo '🧹 Cleaning workspace...'
            cleanWs()
        }
        success {
            echo '✅ All Docker images built and pushed to ECR successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
