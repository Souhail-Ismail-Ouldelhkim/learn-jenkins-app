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

        stage('Test'){
             agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
               steps {
                    sh '''
                      # this is just Test
                      test -f build/index.html
                      npm test
                    '''
               }
        }
    }


     stage('Test E2E '){
             agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.58.2-noble'
                    reuseNode true
                } 
            }
               steps {
                    sh '''
                      # this is just Test
                      npm run build
                      #playwright a besoin d'un url pour Naviguer
                      serve -s build #
                      sleep 4
                      npx playwright test
                    '''
               }
        }
    }

   post {
    always {
        junit 'jest-results/junit.xml'
    }
   }
}