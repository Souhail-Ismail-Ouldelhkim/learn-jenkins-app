pipeline {
    agent any

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            /* this is a comments in jenkins file */

            // a comment have this color
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }

        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            steps {
                sh '''
                    test -f build/index.html
                    npm test
                '''
                sh '#npm ci'
                // cette commande ne sera pas éxécuter
            }
        }
    }

    post {
        always {
            junit 'test-results/junit.xml'
        }
    }
}
