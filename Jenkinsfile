pipeline {
    agent any

    stages {

        /*
        stage('Build steps') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                echo 'Building a new Laptop...'
                sh '''
                    mkdir -p build
                    touch build/computer.txt
                    ls -la
                    npm ci
                    npm run build
                    ls -la
                    node --version
                    npm --version
                    echo "Mainboard" >> build/computer.txt
                    echo "Display" >> build/computer.txt
                    echo "Keyboard" >> build/computer.txt
                    cat build/computer.txt
                '''
            }
        }
        */

        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                echo 'Testing the new Laptop...'
                sh 'test -f build/index.html'
                sh 'npm test'
            }
        }

        stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.52.0-noble'
                    reuseNode true
                }
            }
            steps {
                echo 'Testing project with E2E...'
                sh 'npm install serve'
                sh 'npx serve -s build > serve.log 2>&1 &'
                sh 'sleep 10'
                sh 'npx playwright test'
            }
        }

        /*
        stage('Deploy') {
            steps {
                echo 'Deploying the new Laptop...'
                sh '''
                    echo "Deploying computer configuration..."
                    cp build/computer.txt build/deployment_backup.txt
                    echo "Deployment complete."
                    cat build/deployment_backup.txt
                '''
            }
        }
        */
    }

    post {
        success {
            echo 'Archiving build artifacts...'
            archiveArtifacts artifacts: 'build/*.txt', onlyIfSuccessful: true
        }

        always {
            echo 'Rebuilding the Laptop after cleanup...'
            junit 'jest-results/junit.xml'
            sh '''
                mkdir -p build
                touch build/computer.txt
                echo "Mainboard" >> build/computer.txt
                echo "Display" >> build/computer.txt
                echo "Keyboard" >> build/computer.txt
                cat build/computer.txt
            '''
        }
    }
}
