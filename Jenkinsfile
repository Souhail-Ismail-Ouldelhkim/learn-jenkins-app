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

        stage('E2E') {
            agent {
                docker {
                    image 'docker pull mcr.microsoft.com/playwright:v1.52.0-noble'
                    reuseNode true
                }
            }

            steps {
                sh '''
                    npm install serve
                    node_modules/.bin/serve -s build &
                    npx playwright
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
