pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        AWS_REGION = 'us-east-1'  // 🔁 change to your AWS region
        ECR_REPO_NAME = 'simple-java-app' // 🔁 change to your ECR repo name
        IMAGE_TAG = "latest"
        ACCOUNT_ID = credentials('aws-account-id')  // store your AWS account ID as a Jenkins secret text
        ECR_URI = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Ezehsampson1/simple-java-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
            }
        }

        // 🐳 NEW STAGE: Dockerize and push to AWS ECR
        stage('Dockerize & Push to ECR') {
            steps {
                script {
                    echo "Building Docker image for ECR..."

                    // Login to AWS ECR
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials' // 🔁 add AWS creds in Jenkins
                    ]]) {
                        sh '''
                            aws --version
                            aws ecr get-login-password --region ${AWS_REGION} \
                            | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        '''
                    }

                    // Build and tag the image
                    sh '''
                        docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .
                        docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
                    '''

                    // Push to ECR
                    sh '''
                        docker push ${ECR_URI}:${IMAGE_TAG}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and ECR push completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
